package models

import (
	"context"
	"database/sql"
	"fmt"
	"strconv"
)

type AnalyticsModel struct {
	DB *sql.DB
}

// KeyValue is a single (key, count) pair in a bucket's breakdown. Key is an int
// for bowel types and a string for food tags, so it is typed as any.
type KeyValue struct {
	Key   interface{} `json:"key"`
	Value int         `json:"value"`
}

// Round returns val rounded to two decimal places.
func Round(val float64) float64 {
	str := fmt.Sprintf("%.2f", val)
	roundedVal, _ := strconv.ParseFloat(str, 64)
	return roundedVal
}

// --- 7-day (trailing `days`) analytics: bucketed by day-of-week. ---
// These delegate to the shared per-period executors in analytics_query.go and
// re-key by string ("0".."6") to preserve the JSON shape the app expects.

func (m AnalyticsModel) GetSymptom7DaysOccurrences(ctx context.Context, userID string, symptomID int, days int) (map[int]float64, error) {
	return m.symptomOccurrences(ctx, userID, symptomID, day7Period(days))
}

func (m AnalyticsModel) Get7DaysBowelTypeOccurrences(ctx context.Context, userID string, days int) (map[string][]KeyValue, error) {
	res, err := m.bowelTypeOccurrences(ctx, userID, day7Period(days))
	if err != nil {
		return nil, err
	}
	return stringKeyed(res), nil
}

func (m AnalyticsModel) Get7DaysExerciseOccurrences(ctx context.Context, userID string, days int) (map[string]int, error) {
	res, err := m.exerciseOccurrences(ctx, userID, day7Period(days))
	if err != nil {
		return nil, err
	}
	return stringKeyed(res), nil
}

func (m AnalyticsModel) Get7DaysTagOccurrences(ctx context.Context, userID string, days int, tagToQuery string) (map[string][]KeyValue, error) {
	res, err := m.tagOccurrences(ctx, userID, day7Period(days), tagToQuery)
	if err != nil {
		return nil, err
	}
	return stringKeyed(res), nil
}
