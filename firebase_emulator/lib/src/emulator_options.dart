/// Options for starting a Firebase emulator.
class FirebaseEmulatorOptions {
  /// The Firebase project ID. If null, it is read from `.firebaserc`.
  final String? projectId;

  /// If true, only the Functions emulator is started.
  bool? onlyFunctions;

  /// If true, the emulator is started in debug mode.
  bool? debug;

  /// Creates a new [FirebaseEmulatorOptions].
  FirebaseEmulatorOptions({this.projectId, this.onlyFunctions, this.debug});
}
