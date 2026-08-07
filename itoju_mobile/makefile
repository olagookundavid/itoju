.PHONY: help confirm buildapk buildaab run-local

PROD_URL = https://assistant-marlene-davidoh-6e9342c7.koyeb.app/v1/
LOCAL_URL = http://10.0.2.2:8080/v1/
RELEASE_DIR = /Users/davidoh/Downloads/Itoju_releases

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
	@mkdir -p $(RELEASE_DIR)
	@rm -f $(RELEASE_DIR)/*.apk
	mv build/app/outputs/flutter-apk/app-release.apk $(RELEASE_DIR)/
	@echo 'Moved APK to $(RELEASE_DIR)'

## buildaab: build a release app bundle (Play Store) pointed at the production backend
buildaab:
	@echo 'Building App Bundle...'
	fvm flutter build appbundle --release --dart-define=BASE_URL=$(PROD_URL)
	@mkdir -p $(RELEASE_DIR)
	@rm -f $(RELEASE_DIR)/*.aab
	mv build/app/outputs/bundle/release/app-release.aab $(RELEASE_DIR)/
	@echo 'Moved AAB to $(RELEASE_DIR)'
