import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var mapsApiKey = ""
    if let path = Bundle.main.path(forResource: ".env", ofType: nil) {
        do {
            let envString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = envString.components(separatedBy: .newlines)
            for line in lines {
                if line.starts(with: "GOOGLE_MAPS_API_KEY=") {
                    mapsApiKey = line.replacingOccurrences(of: "GOOGLE_MAPS_API_KEY=", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
                    break
                }
            }
        } catch {
            print("Failed to load .env file")
        }
    }
    
    if !mapsApiKey.isEmpty {
        GMSServices.provideAPIKey(mapsApiKey)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
