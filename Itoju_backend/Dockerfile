# syntax=docker/dockerfile:1

# ---- build stage ----
FROM golang:1.25-alpine AS builder

WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata

# Dependencies are vendored (vendor/ is committed), so the build runs fully
# offline and reproducibly — no `go mod download`, no network at build time.
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -mod=vendor -ldflags="-s -w" -o /app/server ./cmd/main

# ---- runtime stage ----
FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata wget \
    && adduser -D -u 10001 appuser

COPY --from=builder /app/server .

# Drop root — the server binds 8080 (>1024), so no privileged port is needed.
USER appuser

EXPOSE 8080

# Liveness probe for the platform/load balancer.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:8080/v1/healthcheck || exit 1

CMD ["./server"]
