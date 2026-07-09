package service

import (
	"crypto/rand"
	"encoding/hex"
	"strings"
)

// SplitName splits a provider-supplied display name into first/last names,
// falling back to the email local-part when no name is available.
func SplitName(fullName, email string) (first, last string) {
	fullName = strings.TrimSpace(fullName)
	if fullName == "" {
		local := email
		if i := strings.Index(email, "@"); i > 0 {
			local = email[:i]
		}
		return local, "-"
	}
	parts := strings.Fields(fullName)
	if len(parts) == 1 {
		return parts[0], "-"
	}
	return parts[0], strings.Join(parts[1:], " ")
}

// GenerateRandomSecret returns a 32-byte cryptographically-random hex string,
// used as an unusable password for accounts that authenticate via a provider.
func GenerateRandomSecret() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
