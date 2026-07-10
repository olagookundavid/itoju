package models

import (
	"strconv"

	"github.com/google/uuid"
)

// MetricIDArg is the models-layer twin of the api helper: routes a metric row
// id string to (column, value) so a legacy integer id still resolves.
func MetricIDArg(param string) (string, any) {
	if _, err := uuid.Parse(param); err == nil {
		return "id", param
	}
	if n, err := strconv.Atoi(param); err == nil {
		return "legacy_id", n
	}
	return "id", param
}
