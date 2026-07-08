package worker

import (
	"context"
	"io"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/olagookundavid/itoju/internal/jsonlog"
)

func testLogger() *jsonlog.Logger {
	return jsonlog.New(io.Discard, jsonlog.LevelError)
}

func TestPoolRunsAllJobs(t *testing.T) {
	p := NewPool(4, 8, testLogger())
	var count int64
	var wg sync.WaitGroup
	const n = 200 // exceeds queue size to exercise the overflow path too
	wg.Add(n)
	for i := 0; i < n; i++ {
		p.Submit(func() {
			atomic.AddInt64(&count, 1)
			wg.Done()
		})
	}
	wg.Wait()
	p.Shutdown(context.Background())
	if got := atomic.LoadInt64(&count); got != n {
		t.Fatalf("expected %d jobs to run, got %d", n, got)
	}
}

func TestPoolRecoversFromPanic(t *testing.T) {
	p := NewPool(1, 1, testLogger())
	p.Submit(func() { panic("boom") })
	done := make(chan struct{})
	p.Submit(func() { close(done) })
	select {
	case <-done:
	case <-time.After(2 * time.Second):
		t.Fatal("worker did not survive a panicking job")
	}
	p.Shutdown(context.Background())
}

func TestPointsBatcherFlushesAll(t *testing.T) {
	var mu sync.Mutex
	var got []PointEvent
	flush := func(b []PointEvent) error {
		mu.Lock()
		got = append(got, b...)
		mu.Unlock()
		return nil
	}
	b := NewPointsBatcher(flush, 10, 100, 20*time.Millisecond, testLogger())
	const n = 25
	for i := 0; i < n; i++ {
		b.Add(PointEvent{UserID: "u", Scope: "s", Points: 1})
	}
	b.Shutdown(context.Background()) // must flush the remainder

	mu.Lock()
	defer mu.Unlock()
	if len(got) != n {
		t.Fatalf("expected %d flushed events, got %d", n, len(got))
	}
}
