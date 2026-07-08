package models

import (
	"errors"

	"github.com/lib/pq"
)

// pgUniqueViolation is the Postgres SQLSTATE for unique_violation.
const pgUniqueViolation = "23505"

// isUniqueViolation reports whether err is a Postgres unique_violation (23505).
// When constraint is non-empty it must also match the violated constraint name,
// so callers can distinguish e.g. a duplicate email from a duplicate cycle date.
// This replaces brittle matching on the driver's error string.
func isUniqueViolation(err error, constraint string) bool {
	var pqErr *pq.Error
	if !errors.As(err, &pqErr) {
		return false
	}
	if pqErr.Code != pgUniqueViolation {
		return false
	}
	return constraint == "" || pqErr.Constraint == constraint
}
