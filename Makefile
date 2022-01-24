build: build-android build-ios

build-android:
	flutter build appbundle

build-ios:
	fastlane ios build

publish-ios:
	fastlane ios internal

release:
	./scripts/tag_release.sh

test:
	flutter analyze
	flutter test

.PHONY: build test