package firebaseauth

import (
	"context"
	"testing"
	"time"
)

func TestCacheTTL(t *testing.T) {
	tests := []struct {
		name         string
		cacheControl string
		want         time.Duration
	}{
		{"empty falls back to 1h", "", time.Hour},
		{"public max-age", "public, max-age=3600", time.Hour},
		{"max-age with spaces", "max-age=120 , must-revalidate", 120 * time.Second},
		{"zero max-age falls back", "max-age=0", time.Hour},
		{"garbage falls back", "max-age=abc", time.Hour},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := cacheTTL(tt.cacheControl); got != tt.want {
				t.Errorf("cacheTTL(%q) = %v, want %v", tt.cacheControl, got, tt.want)
			}
		})
	}
}

func TestDecodePEMCertRejectsInvalid(t *testing.T) {
	if _, err := decodePEMCert("not a certificate"); err == nil {
		t.Error("expected error for non-PEM input, got nil")
	}
}

func TestVerifyDisabledWithoutProjectID(t *testing.T) {
	v := New("")
	if v.Enabled() {
		t.Fatal("verifier with empty project id should be disabled")
	}
	if _, err := v.Verify(context.Background(), "sometoken"); err != ErrDisabled {
		t.Errorf("want ErrDisabled, got %v", err)
	}
}
