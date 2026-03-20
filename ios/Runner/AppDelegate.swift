import Flutter
import UIKit
import GoogleMaps
import UserNotifications

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

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 앱이 포그라운드 상태일 때도 알림 표시
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
