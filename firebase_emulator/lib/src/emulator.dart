import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:meta/meta.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

/// A running Firebase emulator instance.
class FirebaseEmulator {
  /// The path to the Firebase project directory.
  final String path;

  /// The options used to start the emulator.
  final FirebaseEmulatorOptions options;

  /// The Firebase project ID.
  final String projectId;
  final Shell _shell;
  final Future _done;

  FirebaseEmulator._({
    required this.path,
    required this.options,
    required this.projectId,
    required Shell shell,
    required Future done,
  }) : _shell = shell,
       _done = done;

  /// Stops the emulator.
  Future<void> stop() async {
    try {
      _shell.kill(ProcessSignal.sigkill);
      await _done;
    } catch (_) {}
  }
}

@internal
Future<FirebaseEmulator> createEmulator({
  required String path,
  required FirebaseEmulatorOptions options,
  required Shell shell,
  required Future done,
  required String projectId,
}) async {
  return FirebaseEmulator._(
    path: path,
    options: options,
    projectId: projectId,
    shell: shell,
    done: done,
  );
}
