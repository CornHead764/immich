import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/platform/background_worker_api.g.dart',
    swiftOut: 'ios/Runner/Background/BackgroundWorker.g.swift',
    swiftOptions: SwiftOptions(includeErrorClass: false),
    kotlinOut: 'android/app/src/main/kotlin/app/alextran/immich/background/BackgroundWorker.g.kt',
    kotlinOptions: KotlinOptions(package: 'app.alextran.immich.background'),
    dartOptions: DartOptions(),
    dartPackageName: 'immich_mobile',
  ),
)
class BackgroundWorkerSettings {
  final bool requiresCharging;
  final int minimumDelaySeconds;

  const BackgroundWorkerSettings({required this.requiresCharging, required this.minimumDelaySeconds});
}

/// What asked for an iOS upload run.
///
/// The OS-scheduled tasks tolerate reading slightly stale state, but a run the
/// user asked for has to see the photo they just took, which means syncing and
/// hashing before looking for candidates.
enum IosUploadTrigger { refresh, processing, userInitiated }

@HostApi()
abstract class BackgroundWorkerFgHostApi {
  void enable();

  void saveNotificationMessage(String title, String body);

  void configure(BackgroundWorkerSettings settings);

  void disable();

  // iOS only: Asks the OS for extra runtime so pending uploads can be handed to the
  // background URLSession before the app is suspended
  void beginBackgroundTask();

  // iOS only: Releases the runtime acquired by beginBackgroundTask
  void endBackgroundTask();
}

@HostApi()
abstract class BackgroundWorkerBgHostApi {
  // Called from the background flutter engine when it has bootstrapped and established the
  // required platform channels to notify the native side to start the background upload
  void onInitialized();

  // Called from the background flutter engine to request the native side to cleanup
  void close();
}

@FlutterApi()
abstract class BackgroundWorkerFlutterApi {
  // iOS Only: Called when the iOS background upload is triggered
  @async
  void onIosUpload(IosUploadTrigger trigger, int? maxSeconds);

  // Android Only: Called when the Android background upload is triggered
  @async
  void onAndroidUpload(int? maxMinutes);

  @async
  void cancel();
}
