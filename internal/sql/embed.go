// Package sqlembed embeds the database migration files into the binary so they
// can be applied on startup without shipping the .sql files separately.
package sqlembed

import "embed"

//go:embed migrations/*.sql
var EmbedMigrations embed.FS
