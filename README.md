# totem

## Requirements
- flutter
- xcode
- fastlane

## Release Mobile

1. Switch to 'main' branch.
1. Edit `pubspec.yaml` to increase the version number. At minimum bump the build number (after the `+`).
1. Create a commit with your changes.
1. Run `make release`.
1. Then, when happy with it, you need to promote the Android build in the Play console 

## Release Web

1. Run `make build-web`
1. Run `make publish-web`

## iOS build notes

Error: `doesn't support the X capability.`

When adding capabilities, you need to update the profile, both locally and in the Match repo:

1. Go to the Apple dev website
1. Delete the old "match AppStore io.kbl.totem" profile
1. Create a new profile with the same name as the old one
1. Run `fastlane match && fastlane match appstore` locally in the project folder
1. Check that the profiles in the `totem-keys` repo were updated
1. Now `flutter build ios` should work