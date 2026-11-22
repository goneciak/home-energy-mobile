import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GiHomeBackupExclusion") {
      BackupExclusionChannel.register(with: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GiHomeSecureDisplay") {
      SecureDisplayChannel.shared.register(with: registrar.messenger())
    }
  }
}

/// `gi_home/secure` (plan §M3.5): iOS cannot block screenshots, so while a
/// secret is shown it reports screen recording and mirroring
/// (`UIScreen.isCaptured`) as `captureChanged` and the secret is hidden
/// meanwhile; `copySensitive` puts text on the local-only pasteboard with an
/// expiration date. Dart side: `lib/src/core/platform/secure_display.dart`.
/// Unverified until built on macOS.
final class SecureDisplayChannel {
  static let shared = SecureDisplayChannel()

  private var channel: FlutterMethodChannel?
  private var observer: NSObjectProtocol?

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "gi_home/secure", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      let arguments = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "setSecure":
        self.setSecure((arguments["secure"] as? Bool) ?? false)
        result(nil)
      case "copySensitive":
        let text = (arguments["text"] as? String) ?? ""
        let milliseconds = (arguments["clearAfterMs"] as? NSNumber)?.doubleValue ?? 60_000
        UIPasteboard.general.setItems(
          [["public.utf8-plain-text": text]],
          options: [
            .localOnly: true,
            .expirationDate: Date().addingTimeInterval(milliseconds / 1000),
          ])
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setSecure(_ secure: Bool) {
    if let observer = observer {
      NotificationCenter.default.removeObserver(observer)
      self.observer = nil
    }
    guard secure else { return }
    observer = NotificationCenter.default.addObserver(
      forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.reportCapture()
    }
    reportCapture()
  }

  private func reportCapture() {
    channel?.invokeMethod("captureChanged", arguments: ["captured": UIScreen.main.isCaptured])
  }
}

/// `gi_home/backup` (plan §8.3): keeps app files out of iCloud and Finder
/// backups. Dart side: `lib/src/core/platform/backup_exclusion.dart`.
/// Unverified until built on macOS.
enum BackupExclusionChannel {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "gi_home/backup", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let arguments = call.arguments as? [String: Any],
        let path = arguments["path"] as? String
      else {
        result(FlutterError(code: "bad_arguments", message: "path is required", details: nil))
        return
      }
      var url = URL(fileURLWithPath: path, isDirectory: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      do {
        try url.setResourceValues(values)
        result(nil)
      } catch {
        result(
          FlutterError(code: "exclude_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}
