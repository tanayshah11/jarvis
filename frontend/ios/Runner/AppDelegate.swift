import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register custom plugins using the FlutterPluginRegistry API
    ContactsBridge.register(with: self.registrar(forPlugin: "ContactsBridge")!)
    CalendarBridge.register(with: self.registrar(forPlugin: "CalendarBridge")!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
