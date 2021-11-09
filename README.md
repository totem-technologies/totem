# totem

## App Release

1. Enter the `app` directory.
1. Make sure the `android/key.properties` file exists. See: https://flutter.dev/docs/deployment/android#reference-the-keystore-from-the-app
1. Update the `version` key in `pubspec.yaml`. At least bump the number after `+`. It may also make sense to change the version name depending on the changes.
1. Run `flutter clean && flutter build appbundle` for Android builds.
1. Upload `build/app/outputs/bundle/release/app-release.aab` to the Google Play Store interface (https://play.google.com/console). See: https://developer.android.com/studio/publish/upload-bundle
    1. Click `Internal Testing` on the sidebar
    1. Click blue `Create new release` button on the top right
    1. Upload bundle
    1. Follow prompts