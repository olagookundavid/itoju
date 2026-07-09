package models

import "context"

// Year analytics: bucketed by month-of-year (1-12) within a single calendar
// year. All four delegate to the shared per-period executors in
// analytics_query.go.

func (m AnalyticsModel) GetYearSymptomOccurrences(ctx context.Context, userID string, symptomID int, year int) (map[int]float64, error) {
	return m.symptomOccurrences(ctx, userID, symptomID, yearPeriod(year))
}

func (m AnalyticsModel) GetYearBowelTypeOccurrences(ctx context.Context, userID string, year int) (map[int][]KeyValue, error) {
	return m.bowelTypeOccurrences(ctx, userID, yearPeriod(year))
}

func (m AnalyticsModel) GetYearExerciseTypeOccurrences(ctx context.Context, userID string, year int) (map[int]int, error) {
	return m.exerciseOccurrences(ctx, userID, yearPeriod(year))
}

func (m AnalyticsModel) GetYearTagOccurrences(ctx context.Context, userID string, year int, tagToQuery string) (map[int][]KeyValue, error) {
	return m.tagOccurrences(ctx, userID, yearPeriod(year), tagToQuery)
}
