import Flutter
import UIKit

public class SwiftSuperEasyInAppPurchasePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "super_easy_in_app_purchase", binaryMessenger: registrar.messenger())
    let instance = SwiftSuperEasyInAppPurchasePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
