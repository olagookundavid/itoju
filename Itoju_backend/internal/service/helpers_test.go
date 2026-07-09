package service

import "testing"

func TestSplitName(t *testing.T) {
	tests := []struct {
		name      string
		fullName  string
		email     string
		wantFirst string
		wantLast  string
	}{
		{"full name", "Ada Lovelace", "ada@x.com", "Ada", "Lovelace"},
		{"three parts", "Ada King Lovelace", "ada@x.com", "Ada", "King Lovelace"},
		{"single name", "Ada", "ada@x.com", "Ada", "-"},
		{"empty falls back to email local-part", "", "ada@x.com", "ada", "-"},
		{"whitespace name falls back", "   ", "b@x.com", "b", "-"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			first, last := SplitName(tt.fullName, tt.email)
			if first != tt.wantFirst || last != tt.wantLast {
				t.Errorf("SplitName(%q, %q) = (%q, %q), want (%q, %q)",
					tt.fullName, tt.email, first, last, tt.wantFirst, tt.wantLast)
			}
		})
	}
}
