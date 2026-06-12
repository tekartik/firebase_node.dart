import 'dart:io';

/// Options for starting a Firebase emulator.
class FirebaseEmulatorOptions {
  /// The Firebase project ID. If null, it is read from `.firebaserc`.
  final String? projectId;

  /// If true, only the Functions emulator is started.
  bool? onlyFunctions;

  /// If true, only auth is started
  bool? onlyAuth;

  /// If true, only firestore is started
  bool? onlyFirestore;

  /// If true, only storage is started
  bool? onlyStorage;

  /// If true, the emulator is started in debug mode.
  bool? debug;

  /// Persist path (i.e. not only in memory)
  String? persistPath;

  /// Process start mode
  final ProcessStartMode? processStartMode;

  /// Creates a new [FirebaseEmulatorOptions].
  FirebaseEmulatorOptions({
    this.projectId,
    this.onlyFunctions,
    this.debug,
    this.onlyAuth,
    this.onlyFirestore,
    this.onlyStorage,
    this.persistPath,
    this.processStartMode,
  });
}
