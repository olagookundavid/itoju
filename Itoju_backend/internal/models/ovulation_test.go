package models

import "testing"

// Shared vectors: the Dart implementation (itoju_mobile/lib/data/cycle_math.dart)
// asserts the SAME table in test/data/cycle_math_test.dart. If you change the
// rule, change both.
var ovulationVectors = []struct {
	cycle, period int
	start, end    int // 0-based day indexes of the fertile window, inclusive
	ok            bool
}{
	{28, 5, 8, 13, true},   // textbook: ovulation day 14 (index 13), window days 9-14
	{21, 5, 5, 6, true},    // short cycle: window squeezed after the period
	{35, 5, 15, 20, true},  // long cycle: ovulation moves later
	{30, 7, 10, 15, true},  // 30-day cycle
	{18, 5, 5, 5, true},    // very short: single day right after the period
	{28, 10, 10, 13, true}, // long period eats the front of the window
	{5, 5, 0, 0, false},    // no room after the period
}

func TestOvulationWindow(t *testing.T) {
	for _, v := range ovulationVectors {
		s, e, ok := ovulationWindow(v.period, v.cycle)
		if ok != v.ok || (ok && (s != v.start || e != v.end)) {
			t.Errorf("cycle=%d period=%d: got (%d,%d,%v), want (%d,%d,%v)",
				v.cycle, v.period, s, e, ok, v.start, v.end, v.ok)
		}
	}
}

func TestBuildCycleDaysUsesFertileWindowNotTheWholeSecondHalf(t *testing.T) {
	days := buildCycleDays("c", "u", mustDate("2026-05-01"), 28, 5)
	if len(days) != 28 {
		t.Fatalf("want 28 days, got %d", len(days))
	}
	var period, ovu []int
	for i, d := range days {
		if d.IsPeriod {
			period = append(period, i)
		}
		if d.IsOvulation {
			ovu = append(ovu, i)
		}
		if d.IsPeriod && d.IsOvulation {
			t.Fatalf("day %d is both period and ovulation", i)
		}
	}
	if len(period) != 5 {
		t.Errorf("period days = %v", period)
	}
	if len(ovu) != 6 || ovu[0] != 8 || ovu[5] != 13 {
		t.Errorf("fertile window should be days 8..13 (6 days), got %v", ovu)
	}
}
