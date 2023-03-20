import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Use the debug provider in Debug builds: https://firebase.google.com/docs/app-check/flutter/debug-provider
        #if targetEnvironment(simulator)
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }    
}