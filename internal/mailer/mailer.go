package mailer

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Mailer sends transactional emails via the Resend HTTP API
// (https://resend.com/docs/api-reference/emails/send-email).
//
// It only needs an API key and a verified "from" address, both supplied via
// environment variables (RESEND_API_KEY, RESEND_FROM_EMAIL). No SDK dependency
// is required — Resend exposes a simple JSON endpoint.
type Mailer struct {
	apiKey string
	from   string
	client *http.Client
}

const resendEndpoint = "https://api.resend.com/emails"

// New returns a Mailer. If apiKey or from is empty the mailer is considered
// disabled and Send becomes a no-op that returns an error (so callers can log
// it) without crashing the app — useful for local/dev environments.
func New(apiKey, from string) *Mailer {
	return &Mailer{
		apiKey: apiKey,
		from:   from,
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

// Enabled reports whether the mailer has the credentials it needs to send mail.
func (m *Mailer) Enabled() bool {
	return m != nil && m.apiKey != "" && m.from != ""
}

type sendRequest struct {
	From    string   `json:"from"`
	To      []string `json:"to"`
	Subject string   `json:"subject"`
	Html    string   `json:"html"`
}

// Send delivers a single HTML email. It is safe to call from a background
// goroutine.
func (m *Mailer) Send(to, subject, htmlBody string) error {
	if !m.Enabled() {
		return errors.New("mailer is not configured (missing RESEND_API_KEY or RESEND_FROM_EMAIL)")
	}

	payload, err := json.Marshal(sendRequest{
		From:    m.from,
		To:      []string{to},
		Subject: subject,
		Html:    htmlBody,
	})
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPost, resendEndpoint, bytes.NewReader(payload))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+m.apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := m.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("resend returned status %d: %s", resp.StatusCode, string(body))
	}
	return nil
}

// SendPasswordResetOTP renders and sends the password-reset OTP email.
func (m *Mailer) SendPasswordResetOTP(to, firstName, otp string) error {
	html := passwordResetHTML(firstName, otp)
	return m.Send(to, "Your Itoju password reset code", html)
}

func passwordResetHTML(firstName, otp string) string {
	name := firstName
	if name == "" {
		name = "there"
	}
	return fmt.Sprintf(`<!doctype html>
<html>
  <body style="font-family: Arial, Helvetica, sans-serif; background:#f4f4f7; padding:24px; color:#1a1a1a;">
    <div style="max-width:480px; margin:0 auto; background:#ffffff; border-radius:12px; padding:32px;">
      <h2 style="color:#5142AB; margin-top:0;">Password reset</h2>
      <p>Hi %s,</p>
      <p>Use the code below to reset your Itoju password. This code expires in 15 minutes.</p>
      <div style="font-size:32px; font-weight:700; letter-spacing:8px; text-align:center; color:#5142AB; margin:24px 0;">%s</div>
      <p style="color:#6b7280; font-size:13px;">If you didn't request this, you can safely ignore this email — your password will stay the same.</p>
      <p style="color:#6b7280; font-size:13px;">— The Itoju team</p>
    </div>
  </body>
</html>`, name, otp)
}
