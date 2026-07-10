package models

import (
	"context"
	"fmt"
	"strconv"
	"time"
)

// The 7-day, month and year analytics endpoints run the same four shapes of
// query (symptom severity, bowel type counts, exercise totals, food-tag counts)
// and differ only in three things: the SQL expression that assigns each row to a
// bucket, the date-range predicate, and which buckets to backfill with
// empty/zero values. analyticsPeriod captures exactly those differences so the
// query bodies live in one place instead of being copy-pasted per period.
type analyticsPeriod struct {
	bucket   string // SQL expression producing the integer bucket
	fillFrom int
	fillTo   int // buckets [fillFrom, fillTo] are backfilled; fillTo < fillFrom disables it
	// dateRange builds the WHERE date predicate using positional placeholders
	// beginning at startIdx, together with the args to bind for it.
	dateRange func(startIdx int) (predicate string, args []any)
}

// day7Period buckets by day-of-week (0-6) over the trailing `days` days.
func day7Period(days int) analyticsPeriod {
	return analyticsPeriod{
		bucket:   "EXTRACT(DOW FROM date)",
		fillFrom: 0, fillTo: 6,
		dateRange: func(i int) (string, []any) {
			return fmt.Sprintf("date >= CURRENT_DATE - make_interval(days => $%d)", i), []any{days}
		},
	}
}

// monthPeriod buckets by week-of-month (1-5) within a single calendar month.
func monthPeriod(year, month int) analyticsPeriod {
	return analyticsPeriod{
		bucket:   "(EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM date_trunc('month', date)) + 1)",
		fillFrom: 1, fillTo: 5,
		dateRange: func(i int) (string, []any) {
			return fmt.Sprintf("date >= make_date($%d, $%d, 1) AND date < make_date($%d, $%d, 1) + INTERVAL '1 month'", i, i+1, i, i+1), []any{year, month}
		},
	}
}

// yearPeriod buckets by month-of-year (1-12) within a single calendar year.
func yearPeriod(year int) analyticsPeriod {
	return analyticsPeriod{
		bucket:   "EXTRACT(MONTH FROM date)",
		fillFrom: 1, fillTo: 12,
		dateRange: func(i int) (string, []any) {
			return fmt.Sprintf("date >= make_date($%d, 1, 1) AND date < make_date($%d + 1, 1, 1)", i, i), []any{year}
		},
	}
}

// symptomOccurrences returns the average symptom severity per bucket. The map is
// sparse (no backfill), matching the original per-period methods.
func (m AnalyticsModel) symptomOccurrences(ctx context.Context, userID string, symptomID int, p analyticsPeriod) (map[int]float64, error) {
	dr, dargs := p.dateRange(3) // $1 user, $2 symptom, date args from $3
	query := fmt.Sprintf(`
		SELECT %s AS bucket,
			AVG((morning_severity + afternoon_severity + night_severity) / 3) AS average_severity
		FROM user_symptoms_metric
		WHERE user_id = $1 AND symptoms_id = $2 AND deleted_at IS NULL AND %s
		GROUP BY bucket
		ORDER BY bucket;`, p.bucket, dr)

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, append([]any{userID, symptomID}, dargs...)...)
	if err != nil {
		return nil, fmt.Errorf("query error: %v", err)
	}
	defer rows.Close()

	res := make(map[int]float64)
	for rows.Next() {
		var bucket int
		var avg float64
		if err := rows.Scan(&bucket, &avg); err != nil {
			return nil, fmt.Errorf("scan error: %v", err)
		}
		res[bucket] = Round(avg)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return res, nil
}

// bowelTypeOccurrences returns, per bucket, the count of each bowel type,
// backfilling empty buckets.
func (m AnalyticsModel) bowelTypeOccurrences(ctx context.Context, userID string, p analyticsPeriod) (map[int][]KeyValue, error) {
	dr, dargs := p.dateRange(2)
	query := fmt.Sprintf(`
		SELECT %s AS bucket, type, COUNT(*) AS occurrences
		FROM user_bowel_metric
		WHERE user_id = $1 AND deleted_at IS NULL AND %s
		GROUP BY bucket, type
		ORDER BY bucket, type;`, p.bucket, dr)

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, append([]any{userID}, dargs...)...)
	if err != nil {
		return nil, fmt.Errorf("query error: %v", err)
	}
	defer rows.Close()

	res := make(map[int][]KeyValue)
	for rows.Next() {
		var bucket, typeID, occ int
		if err := rows.Scan(&bucket, &typeID, &occ); err != nil {
			return nil, fmt.Errorf("scan error: %v", err)
		}
		res[bucket] = append(res[bucket], KeyValue{Key: typeID, Value: occ})
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	backfillKV(res, p)
	return res, nil
}

// exerciseOccurrences returns the total exercises per bucket, backfilling empty
// buckets with 0.
func (m AnalyticsModel) exerciseOccurrences(ctx context.Context, userID string, p analyticsPeriod) (map[int]int, error) {
	dr, dargs := p.dateRange(2)
	query := fmt.Sprintf(`
		SELECT %s AS bucket, SUM(no_of_times) AS total_exercises
		FROM user_exercise_metric
		WHERE user_id = $1 AND deleted_at IS NULL AND %s
		GROUP BY bucket
		ORDER BY bucket;`, p.bucket, dr)

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, append([]any{userID}, dargs...)...)
	if err != nil {
		return nil, fmt.Errorf("query error: %v", err)
	}
	defer rows.Close()

	res := make(map[int]int)
	for rows.Next() {
		var bucket, total int
		if err := rows.Scan(&bucket, &total); err != nil {
			return nil, fmt.Errorf("scan error: %v", err)
		}
		res[bucket] = total
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	for i := p.fillFrom; i <= p.fillTo; i++ {
		if _, ok := res[i]; !ok {
			res[i] = 0
		}
	}
	return res, nil
}

// tagOccurrences returns, per bucket, the count of each food tag (optionally
// filtered to a single tag), backfilling empty buckets. It scans all four meal
// tag arrays (breakfast/lunch/dinner/snack) via a shared UNION-ALL CTE.
func (m AnalyticsModel) tagOccurrences(ctx context.Context, userID string, p analyticsPeriod, tagToQuery string) (map[int][]KeyValue, error) {
	dr, dargs := p.dateRange(2)
	args := append([]any{userID}, dargs...)

	var query string
	if tagToQuery == "" {
		query = tagOccurrencesCTE(p.bucket, dr) + `
		SELECT bucket, tag, COUNT(*) AS occurrences
		FROM tag_occurrences
		GROUP BY bucket, tag
		ORDER BY bucket, tag;`
	} else {
		tagIdx := 2 + len(dargs) // placeholder after userID + date args
		query = tagOccurrencesCTE(p.bucket, dr) + fmt.Sprintf(`
		SELECT bucket, tag, COUNT(*) AS occurrences
		FROM tag_occurrences
		WHERE tag = $%d
		GROUP BY bucket, tag
		ORDER BY bucket, tag;`, tagIdx)
		args = append(args, tagToQuery)
	}

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("query error: %v", err)
	}
	defer rows.Close()

	res := make(map[int][]KeyValue)
	for rows.Next() {
		var bucket, occ int
		var tag string
		if err := rows.Scan(&bucket, &tag, &occ); err != nil {
			return nil, fmt.Errorf("scan error: %v", err)
		}
		res[bucket] = append(res[bucket], KeyValue{Key: tag, Value: occ})
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	backfillKV(res, p)
	return res, nil
}

// tagOccurrencesCTE builds the WITH clause that flattens the four meal tag arrays
// into (bucket, tag) rows for the given bucket expression and date predicate.
// user_id is always $1. The four tag columns are NOT NULL DEFAULT '{}', so
// concatenating them and unnesting once scans user_food_metric a single time
// instead of the four self-UNIONed scans the per-period methods used to do.
func tagOccurrencesCTE(bucket, dateRange string) string {
	return fmt.Sprintf(`WITH tag_occurrences AS (
		SELECT %s AS bucket,
			UNNEST(breakfast_tags || lunch_tags || dinner_tags || snack_tags) AS tag
		FROM user_food_metric
		WHERE user_id = $1 AND deleted_at IS NULL AND %s)`, bucket, dateRange)
}

// backfillKV ensures every bucket in [fillFrom, fillTo] is present with at least
// an empty slice, so charts render a full axis.
func backfillKV(res map[int][]KeyValue, p analyticsPeriod) {
	for i := p.fillFrom; i <= p.fillTo; i++ {
		if _, ok := res[i]; !ok {
			res[i] = []KeyValue{}
		}
	}
}

// stringKeyed re-keys an int-bucketed map by its decimal string, preserving the
// exact JSON shape the 7-day endpoints have always returned (e.g. {"0":..}).
func stringKeyed[V any](in map[int]V) map[string]V {
	out := make(map[string]V, len(in))
	for k, v := range in {
		out[strconv.Itoa(k)] = v
	}
	return out
}
