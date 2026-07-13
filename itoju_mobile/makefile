.PHONY: help confirm buildapk buildaab run-local

PROD_URL = https://sensible-charita-mercyjae-71eea44d.koyeb.app/v1/
LOCAL_URL = http://10.0.2.2:8080/v1/

help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'


confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run-local: run the app against a local backend (Android emulator)
run-local:
	fvm flutter run --dart-define=BASE_URL=$(LOCAL_URL)

# ==================================================================================== #
# RELEASE
# ==================================================================================== #

## buildapk: build a release APK pointed at the production backend
buildapk:
	@echo 'Building Apk...'
	fvm flutter build apk --release --dart-define=BASE_URL=$(PROD_URL)

## buildaab: build a release app bundle (Play Store) pointed at the production backend
buildaab:
	@echo 'Building App Bundle...'
	fvm flutter build appbundle --release --dart-define=BASE_URL=$(PROD_URL)
