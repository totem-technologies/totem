build: build-android build-ios .git/hooks/pre-commit

build-android:
	flutter build appbundle

publish-andorid:
	fastlane android internal

build-ios:
	fastlane ios build

publish-ios:
	fastlane ios internal

build-web: clean
	rm -rf build/web
	flutter build web --release

publish-web: build-web
	firebase deploy --only hosting

run-web:
	firebase emulators:start

release: test
	./scripts/tag_release.sh
	$(MAKE) publish-web

test:
	flutter analyze
	flutter test

clean:
	flutter clean

install_hooks: .git/hooks/pre-commit

# check if git hooks exits; if it does then create pre commit hook by linking pre-commit.sh
.git/hooks/pre-commit:
	[ ! -d .git/hooks ] || [ -L .git/hooks/pre-commit ] || ln -s -f ../../githooks/pre-commit.sh .git/hooks/pre-commit

.PHONY: build test