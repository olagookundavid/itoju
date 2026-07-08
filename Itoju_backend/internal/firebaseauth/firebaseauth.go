// Package firebaseauth verifies Firebase-issued ID tokens server-side.
//
// The mobile client performs Google Sign-In through Firebase Auth and sends the
// resulting Firebase ID token to the API. This package validates that token's
// signature, issuer, audience and expiry against Google's public certificates,
// so the server can trust the caller's identity instead of a client-supplied
// email.
//
// Only the Firebase project ID is required (FIREBASE_PROJECT_ID); ID-token
// verification uses Google's public certificates and does NOT need a
// service-account private key. This mirrors what the Firebase Admin SDK does
// under the hood, without pulling in its large dependency tree.
package firebaseauth

import (
	"context"
	"crypto/rsa"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// googleCertsURL serves the x509 certificates used to sign Firebase ID tokens,
// keyed by the token header's "kid".
const googleCertsURL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

// ErrDisabled is returned when verification is attempted but no Firebase
// project ID was configured (social login is effectively turned off).
var ErrDisabled = errors.New("firebase auth is not configured")

// Verifier validates Firebase ID tokens for a single project.
type Verifier struct {
	projectID  string
	httpClient *http.Client

	mu       sync.Mutex
	certs    map[string]*rsa.PublicKey
	certsExp time.Time // when the cached certs should be refreshed
}

// Identity is the trusted subset of claims extracted from a verified ID token.
type Identity struct {
	UID           string
	Email         string
	EmailVerified bool
	Name          string
}

// New builds a Verifier for the given Firebase project ID. When projectID is
// empty it returns a disabled Verifier whose Verify method returns ErrDisabled,
// mirroring how the mailer degrades gracefully when unconfigured.
func New(projectID string) *Verifier {
	return &Verifier{
		projectID:  projectID,
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

// Enabled reports whether a Firebase project ID was configured.
func (v *Verifier) Enabled() bool { return v.projectID != "" }

// Verify validates a Firebase ID token and returns the trusted identity. It
// checks the RS256 signature against Google's certs and enforces the expected
// issuer, audience (project ID) and expiry.
func (v *Verifier) Verify(ctx context.Context, idToken string) (*Identity, error) {
	if v.projectID == "" {
		return nil, ErrDisabled
	}

	claims := jwt.MapClaims{}
	parser := jwt.NewParser(
		jwt.WithValidMethods([]string{"RS256"}),
		jwt.WithIssuer("https://securetoken.google.com/"+v.projectID),
		jwt.WithAudience(v.projectID),
		jwt.WithExpirationRequired(),
	)

	_, err := parser.ParseWithClaims(idToken, claims, func(token *jwt.Token) (any, error) {
		kid, ok := token.Header["kid"].(string)
		if !ok || kid == "" {
			return nil, errors.New("id token missing kid header")
		}
		return v.keyForKID(ctx, kid)
	})
	if err != nil {
		return nil, err
	}

	// Firebase requires a non-empty subject (the user's UID).
	sub, err := claims.GetSubject()
	if err != nil || sub == "" {
		return nil, errors.New("id token missing subject")
	}

	id := &Identity{UID: sub}
	if email, ok := claims["email"].(string); ok {
		id.Email = email
	}
	if verified, ok := claims["email_verified"].(bool); ok {
		id.EmailVerified = verified
	}
	if name, ok := claims["name"].(string); ok {
		id.Name = name
	}
	return id, nil
}

// keyForKID returns the RSA public key for a given key id, refreshing the cache
// from Google when the kid is unknown or the cache has expired.
func (v *Verifier) keyForKID(ctx context.Context, kid string) (*rsa.PublicKey, error) {
	v.mu.Lock()
	if key, ok := v.certs[kid]; ok && time.Now().Before(v.certsExp) {
		v.mu.Unlock()
		return key, nil
	}
	v.mu.Unlock()

	if err := v.refreshCerts(ctx); err != nil {
		return nil, err
	}

	v.mu.Lock()
	defer v.mu.Unlock()
	key, ok := v.certs[kid]
	if !ok {
		return nil, fmt.Errorf("no public key found for kid %q", kid)
	}
	return key, nil
}

// refreshCerts fetches and parses Google's signing certificates, honouring the
// Cache-Control max-age so we don't hammer the endpoint on every request.
func (v *Verifier) refreshCerts(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, googleCertsURL, nil)
	if err != nil {
		return err
	}
	resp, err := v.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("fetching google certs: unexpected status %d", resp.StatusCode)
	}

	var raw map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return err
	}

	certs := make(map[string]*rsa.PublicKey, len(raw))
	for kid, pemCert := range raw {
		block, _ := decodePEMCert(pemCert)
		if block == nil {
			continue
		}
		cert, err := x509.ParseCertificate(block)
		if err != nil {
			continue
		}
		if pub, ok := cert.PublicKey.(*rsa.PublicKey); ok {
			certs[kid] = pub
		}
	}
	if len(certs) == 0 {
		return errors.New("no usable google signing certificates returned")
	}

	v.mu.Lock()
	v.certs = certs
	v.certsExp = time.Now().Add(cacheTTL(resp.Header.Get("Cache-Control")))
	v.mu.Unlock()
	return nil
}

// decodePEMCert extracts the DER bytes of the first CERTIFICATE block in a PEM
// string without pulling in encoding/pem's block chaining semantics.
func decodePEMCert(pemStr string) ([]byte, error) {
	const header = "-----BEGIN CERTIFICATE-----"
	const footer = "-----END CERTIFICATE-----"
	start := strings.Index(pemStr, header)
	end := strings.Index(pemStr, footer)
	if start == -1 || end == -1 || end < start {
		return nil, errors.New("invalid certificate PEM")
	}
	body := strings.TrimSpace(pemStr[start+len(header) : end])
	body = strings.ReplaceAll(body, "\n", "")
	body = strings.ReplaceAll(body, "\r", "")
	der, err := base64.StdEncoding.DecodeString(body)
	if err != nil {
		return nil, err
	}
	return der, nil
}

// cacheTTL parses a Cache-Control header value and returns its max-age, falling
// back to one hour when absent or unparseable.
func cacheTTL(cacheControl string) time.Duration {
	const fallback = time.Hour
	for _, part := range strings.Split(cacheControl, ",") {
		part = strings.TrimSpace(part)
		if strings.HasPrefix(part, "max-age=") {
			if secs, err := strconv.Atoi(strings.TrimPrefix(part, "max-age=")); err == nil && secs > 0 {
				return time.Duration(secs) * time.Second
			}
		}
	}
	return fallback
}
