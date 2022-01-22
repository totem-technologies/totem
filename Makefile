build: build-android build-ios

build-ios:
	pod repo update
	flutter build ios

build-android:
# For firebase
	flutter build apk
# For google play
	flutter build appbundle

devpublish:
	firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app 1:35349008308:android:8be76d38d68eed40206ce1 --release-notes "Bug fixes and improvements" --groups "developers"

test:
	flutter analyze
	flutter test

.PHONY: build