# Itoju

Symptom and wellness tracking app.

| Directory | What it is | Stack |
|---|---|---|
| [`Itoju_backend/`](Itoju_backend/) | REST API (deployed on Koyeb) | Go, PostgreSQL |
| [`itoju_mobile/`](itoju_mobile/) | Mobile app | Flutter (managed with fvm) |

## Backend

```bash
cd Itoju_backend
make run/api        # see makefile for targets
go test ./...
```

## Mobile

```bash
cd itoju_mobile
fvm flutter pub get
make run-local      # run against a local backend (Android emulator)
make buildapk       # release APK pointed at production
```

The backend base URL is injected at build time via `--dart-define=BASE_URL=...`;
the makefile targets set it for you.

## CI

GitHub Actions run per project using path filters: backend changes trigger
`backend.yml` (vet, build, test), mobile changes trigger `mobile.yml`
(analyze). A commit touching only one side won't run the other's checks.
