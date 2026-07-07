// Package worker provides a bounded background-job pool and a batching
// aggregator, replacing the previous unbounded "one goroutine per call"
// app.Background pattern. The pool caps concurrency (so a traffic spike can't
// spawn thousands of goroutines / DB connections) while never blocking the
// request path, and drains cleanly on shutdown.
package worker

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"

	"github.com/olagookundavid/itoju/internal/jsonlog"
)

// Pool is a fixed set of workers consuming fire-and-forget jobs from a buffered
// queue. Panics inside a job are recovered and logged, never taking the process
// down.
type Pool struct {
	jobs   chan func()
	wg     sync.WaitGroup
	logger *jsonlog.Logger
	closed atomic.Bool
}

// NewPool starts `workers` goroutines draining a queue of `queueSize`.
func NewPool(workers, queueSize int, logger *jsonlog.Logger) *Pool {
	if workers < 1 {
		workers = 1
	}
	if queueSize < 1 {
		queueSize = 1
	}
	p := &Pool{jobs: make(chan func(), queueSize), logger: logger}
	for i := 0; i < workers; i++ {
		p.wg.Add(1)
		go p.worker()
	}
	return p
}

func (p *Pool) worker() {
	defer p.wg.Done()
	for fn := range p.jobs {
		p.run(fn)
	}
}

// run executes a job with panic recovery so one bad job can't kill a worker.
func (p *Pool) run(fn func()) {
	defer func() {
		if r := recover(); r != nil {
			p.logger.PrintError(fmt.Errorf("background job panic: %v", r), nil)
		}
	}()
	fn()
}

// Submit enqueues a job. It never blocks the caller: if the queue is full it
// runs the job in an overflow goroutine so work is neither dropped nor allowed
// to stall the request path. Jobs submitted after Shutdown run detached.
func (p *Pool) Submit(fn func()) {
	if p.closed.Load() {
		p.wg.Add(1)
		go func() { defer p.wg.Done(); p.run(fn) }()
		return
	}
	select {
	case p.jobs <- fn:
	default:
		// Queue saturated — overflow rather than block or drop.
		p.logger.PrintInfo("worker pool queue saturated; running job in overflow goroutine", nil)
		p.wg.Add(1)
		go func() { defer p.wg.Done(); p.run(fn) }()
	}
}

// Shutdown stops accepting new queued jobs and waits for in-flight and queued
// jobs to finish, bounded by ctx.
func (p *Pool) Shutdown(ctx context.Context) {
	if p.closed.Swap(true) {
		return
	}
	close(p.jobs)
	done := make(chan struct{})
	go func() {
		p.wg.Wait()
		close(done)
	}()
	select {
	case <-done:
	case <-ctx.Done():
		p.logger.PrintError(fmt.Errorf("worker pool shutdown timed out with jobs still running"), nil)
	}
}
