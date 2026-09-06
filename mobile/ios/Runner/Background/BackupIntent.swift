import AppIntents

/// Exposes the upload worker to the Shortcuts app, so a personal automation (for example
/// "when the Camera app is closed") can back up new photos without opening Immich.
/// iOS launches the app in the background to run this, which is a far more predictable
/// trigger than waiting for BGTaskScheduler.
@available(iOS 16.4, *)
struct BackupIntent: AppIntent {
  static let title: LocalizedStringResource = "Back up now"
  static let description = IntentDescription("Uploads new photos and videos to your Immich server.")
  static let openAppWhenRun = false

  func perform() async throws -> some IntentResult {
    await BackgroundWorkerApiImpl.runUploadWorker()
    return .result()
  }
}

@available(iOS 16.4, *)
struct ImmichAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: BackupIntent(),
      phrases: ["Back up with \(.applicationName)"],
      shortTitle: "Back up now",
      systemImageName: "arrow.up.circle"
    )
  }
}
