package models

import (
	"errors"

	"github.com/lib/pq"
)

// pgUniqueViolation is the Postgres SQLSTATE for unique_violation.
const pgUniqueViolation = "23505"

// pgForeignKeyViolation is the Postgres SQLSTATE for foreign_key_violation.
const pgForeignKeyViolation = "23503"

// IsForeignKeyViolation reports whether err is a Postgres foreign_key_violation
// (23503) — e.g. a subscriptions upsert whose user_id has no matching users row,
// which happens for a RevenueCat webhook that arrives before the anonymous
// purchase is bound to a server account.
func IsForeignKeyViolation(err error) bool {
	var pqErr *pq.Error
	if !errors.As(err, &pqErr) {
		return false
	}
	return pqErr.Code == pgForeignKeyViolation
}

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
