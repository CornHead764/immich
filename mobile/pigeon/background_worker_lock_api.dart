import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/platform/background_worker_lock_api.g.dart',
    swiftOut: 'ios/Runner/Background/BackgroundWorkerLock.g.swift',
    swiftOptions: SwiftOptions(includeErrorClass: false),
    kotlinOut: 'android/app/src/main/kotlin/app/alextran/immich/background/BackgroundWorkerLock.g.kt',
    kotlinOptions: KotlinOptions(package: 'app.alextran.immich.background', includeErrorClass: false),
    dartOptions: DartOptions(),
    dartPackageName: 'immich_mobile',
  ),
)
/// Claims the upload pipeline for the app itself.
///
/// Only one of the app and a background worker may back up at a time: they run
/// in separate isolates over one database and one export directory, and both
/// picking up the same asset means uploading it twice and deleting the file out
/// from under the other. The app wins — a worker holding it is cancelled.
@HostApi()
abstract class BackgroundWorkerLockApi {
  void lock();

  void unlock();
}
