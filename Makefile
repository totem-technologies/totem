build: build-android build-ios

build-ios:
	pod repo update
	flutter build ipa

build-android:
	flutter build appbundle

publish-ios:
	fastlane ios internal

release:
	./scripts/tag_release.sh

test:
	flutter analyze
	flutter test

.PHONY: build test