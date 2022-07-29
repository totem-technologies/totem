build: build-android build-ios

build-android:
	flutter build appbundle

publish-andorid:
	fastlane android internal

build-ios:
	fastlane ios build

publish-ios:
	fastlane ios internal

build-web:
	rm -rf build/web
	flutter build web --release

publish-web: build-web
	firebase deploy --only hosting

run-web:
	firebase emulators:start

release: test
	./scripts/tag_release.sh

test:
	flutter analyze
	flutter test

clean:
	flutter clean

.PHONY: build test