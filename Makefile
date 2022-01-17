build: build-android build-ios

build-ios:
	pod repo update
	flutter build ipa
	xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive -exportPath build/ios/archive -exportOptionsPlist build/ios/archive/Runner.xcarchive/info.plist
	echo "Built build/ios/archive/totem.ipa"

build-android:
	flutter build apk

devpublish:
	firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app 1:35349008308:android:8be76d38d68eed40206ce1 --release-notes "Bug fixes and improvements" --groups "developers"
	firebase appdistribution:distribute build/ios/archive/totem.ipa --app 1:35349008308:ios:bd903a0a3c9a995b206ce1 --release-notes "Bug fixes and improvements" --groups "developers"

test:
	flutter analyze
	flutter test

.PHONY: build