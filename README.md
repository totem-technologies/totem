# Totem
Bringing people together to heal.

## Requirements
- flutter
- xcode
- fastlane
- gitleaks (brew install gitleaks)

## Setup
1. Run `make install_hooks` to make sure no secrets are committed.

## Firebase emulator

1. You will need to run this command once:
   - `cd server/functions; firebase functions:config:get > .runtimeconfig.json`
   - ***NOTE:*** This file should never be checked in as it contains secrets (it's in the .gitignore)
2. Make sure you have node version 14 installed locally
   - If you are using nvm to manage node: `nvm install 14` or if already installed `nvm use 14`
3. Start the local firebase emulator:
   - Make sure to install the firebase cli: `npm install -g firebase-tools`
   - Change directory to functions `cd server/functions`
   - Install node modules: `npm install`
   - Start the server: `npm run serve`
   -or-
   - From VSCode click the start button next to the "serve" line under 'NPM Scripts'
5. Run the totem flutter application with the environment variable `USE_EMULATOR=true`
   - For VSCode there is a checked in configuration in the `launch.json` file.
   - For Android Studio, create a new configuration with the run args `--dart-define=USE_EMULATOR=true`
6. Since the emulator runs on localhost, you will need to either use web or a device emulator as the target device.
   - It will work for an Android device attached to the local system
7. To trigger the scheduler to run locally in your emulator, you can use the following command:
   - `curl http://localhost:5001/totem-dev-184f1/us-central1/runScheduler`
   
## Release

1. Switch to 'main' branch: `git checkout main`
1. Edit `pubspec.yaml` to increase the version number. At minimum bump the build number (after the `+`).
1. Create a commit with your changes. Usually in the form of `git commit -m "v1.4.2+15"`
1. Run `make release`. This adds a tag with the version number and pushes everything online.
1. Soon, the web code will be live: https://app.totem.org/
1. Then, when happy with it, you need to promote the Android build in the Play console (https://play.google.com/console/u/0/developers/6048825475784314007/app/4973577798809786425/tracks/4699484839665024268/releases/11/prepare)
1. Additionally, the iOS app needs to be released to external testers at (https://appstoreconnect.apple.com/apps/1591746908/testflight/groups/d57a217c-7e77-4865-98a4-c663ac913bd1)
1. Archive the `Done` tickets: https://github.com/orgs/totem-technologies/projects/1/views/1

## iOS build notes

Error: `doesn't support the X capability.`

When adding capabilities, you need to update the profile, both locally and in the Match repo:

1. Go to the Apple dev website
1. Delete the old "match AppStore io.kbl.totem" profile
1. Create a new profile with the same name as the old one
1. Run `fastlane match && fastlane match appstore` locally in the project folder
1. Check that the profiles in the `totem-keys` repo were updated
1. Now `flutter build ios` should work