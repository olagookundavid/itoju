package worker

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/olagookundavid/itoju/internal/jsonlog"
)

// PointEvent is a single "award N points to a user for scope" fact.
type PointEvent struct {
	UserID string
	Scope  string
	Points int64
}

// PointsBatcher coalesces high-frequency point awards and flushes them in
// batches, turning many tiny per-request transactions into one bulk write.
// It is intentionally decoupled from the DB: the caller supplies `flush`.
type PointsBatcher struct {
	events   chan PointEvent
	flush    func([]PointEvent) error
	maxBatch int
	interval time.Duration
	logger   *jsonlog.Logger
	wg       sync.WaitGroup

	// mu makes "is the batcher still open?" and the channel send one atomic step
	// (see Pool.mu). Add holds the read lock; Shutdown the write lock.
	mu     sync.RWMutex
	closed bool
}

// NewPointsBatcher starts the aggregation loop. Events are flushed when either
// `maxBatch` accumulate or `interval` elapses. `buffer` bounds the in-memory
// queue before overflow handling kicks in.
func NewPointsBatcher(flush func([]PointEvent) error, maxBatch, buffer int, interval time.Duration, logger *jsonlog.Logger) *PointsBatcher {
	if maxBatch < 1 {
		maxBatch = 1
	}
	if buffer < 1 {
		buffer = 1
	}
	if interval <= 0 {
		interval = time.Second
	}
	b := &PointsBatcher{
		events:   make(chan PointEvent, buffer),
		flush:    flush,
		maxBatch: maxBatch,
		interval: interval,
		logger:   logger,
	}
	b.wg.Add(1)
	go b.loop()
	return b
}

// Add enqueues a point award. Non-blocking: if the buffer is full it flushes the
// single event in an overflow goroutine so no points are lost and the request
// path never stalls. After Shutdown the event is flushed inline (still not lost,
// and nothing is sent on the closed channel).
func (b *PointsBatcher) Add(e PointEvent) {
	b.mu.RLock()
	if b.closed {
		b.mu.RUnlock()
		b.safeFlush([]PointEvent{e})
		return
	}
	select {
	case b.events <- e:
	default:
		b.logger.PrintInfo("points batcher buffer full; flushing single event via overflow", nil)
		b.overflow([]PointEvent{e})
	}
	b.mu.RUnlock()
}

func (b *PointsBatcher) overflow(batch []PointEvent) {
	b.wg.Add(1)
	go func() {
		defer b.wg.Done()
		b.safeFlush(batch)
	}()
}

func (b *PointsBatcher) loop() {
	defer b.wg.Done()
	ticker := time.NewTicker(b.interval)
	defer ticker.Stop()

	batch := make([]PointEvent, 0, b.maxBatch)
	flush := func() {
		if len(batch) == 0 {
			return
		}
		b.safeFlush(batch)
		batch = make([]PointEvent, 0, b.maxBatch)
	}

	for {
		select {
		case e, ok := <-b.events:
			if !ok {
				flush() // channel closed on shutdown: flush the remainder and stop
				return
			}
			batch = append(batch, e)
			if len(batch) >= b.maxBatch {
				flush()
			}
		case <-ticker.C:
			flush()
		}
	}
}

func (b *PointsBatcher) safeFlush(batch []PointEvent) {
	defer func() {
		if r := recover(); r != nil {
			b.logger.PrintError(fmt.Errorf("points flush panic: %v", r), nil)
		}
	}()
	if err := b.flush(batch); err != nil {
		b.logger.PrintError(fmt.Errorf("points flush failed for %d events: %w", len(batch), err), nil)
	}
}

// Shutdown stops intake and flushes any buffered events, bounded by ctx.
func (b *PointsBatcher) Shutdown(ctx context.Context) {
	b.mu.Lock()
	if !b.closed {
		b.closed = true
		close(b.events)
	}
	b.mu.Unlock()
	done := make(chan struct{})
	go func() {
		b.wg.Wait()
		close(done)
	}()
	select {
	case <-done:
	case <-ctx.Done():
		b.logger.PrintError(fmt.Errorf("points batcher shutdown timed out"), nil)
	}
}
