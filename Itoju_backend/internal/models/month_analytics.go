package models

import "context"

// Month analytics: bucketed by week-of-month (1-5) within a single calendar
// month. All four delegate to the shared per-period executors in
// analytics_query.go.

func (m AnalyticsModel) GetMonthSymptomOccurrences(ctx context.Context, userID string, symptomID int, year int, month int) (map[int]float64, error) {
	return m.symptomOccurrences(ctx, userID, symptomID, monthPeriod(year, month))
}

func (m AnalyticsModel) GetMonthBowelTypeOccurrences(ctx context.Context, userID string, year int, month int) (map[int][]KeyValue, error) {
	return m.bowelTypeOccurrences(ctx, userID, monthPeriod(year, month))
}

func (m AnalyticsModel) GetMonthExerciseTypeOccurrences(ctx context.Context, userID string, year int, month int) (map[int]int, error) {
	return m.exerciseOccurrences(ctx, userID, monthPeriod(year, month))
}

func (m AnalyticsModel) GetMonthTagOccurrences(ctx context.Context, userID string, year int, month int, tagToQuery string) (map[int][]KeyValue, error) {
	return m.tagOccurrences(ctx, userID, monthPeriod(year, month), tagToQuery)
}
