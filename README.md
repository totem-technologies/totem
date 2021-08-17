# totem

## Release

1. Make sure the `android/key.properties` file exists. See: https://flutter.dev/docs/deployment/android#reference-the-keystore-from-the-app
1. Update the `version` key in `pubspec.yaml`. At least bump the number after `+`. It may also make sense to change the version name depending on the changes.
1. Run `flutter clean && flutter build appbundle` for Android builds.
1. Upload `build/app/outputs/bundle/release/app-release.aab` to the Google Play Store interface. See: https://developer.android.com/studio/publish/upload-bundle