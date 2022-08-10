# totem

## Requirements
- flutter
- xcode
- fastlane
- gitleaks (brew install gitleaks)

## Setup
1. Run `make install_hooks` to make sure no secrets are committed.

## Release Mobile

1. Switch to 'main' branch.
1. Edit `pubspec.yaml` to increase the version number. At minimum bump the build number (after the `+`).
1. Create a commit with your changes. Usually in the form of `git commit -m "v1.4.2+15"`
1. Run `make release`.
1. Then, when happy with it, you need to promote the Android build in the Play console (https://play.google.com/console/u/0/developers/6048825475784314007/app/4973577798809786425/tracks/4699484839665024268/releases/11/prepare)
1. Additionally, the iOS app needs to be released to external testers at (https://appstoreconnect.apple.com/apps/1591746908/testflight/groups/d57a217c-7e77-4865-98a4-c663ac913bd1)
1. Archive the `Done` tickets: https://github.com/orgs/totem-technologies/projects/1/views/1

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