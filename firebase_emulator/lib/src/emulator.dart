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
    required this._shell,
    required this._done,
  });

  /// Stops the emulator.
  Future<void> stop() async {
    try {
      // _shell.kill(ProcessSignal.sigkill);
      _shell.kill(ProcessSignal.sigint);
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

/// A running Firebase emulator instance.
class FirebaseRunningEmulator implements FirebaseEmulator {
  @override
  Future<dynamic> get _done => throw UnimplementedError();

  @override
  Shell get _shell => throw UnimplementedError();

  @override
  FirebaseEmulatorOptions get options => throw UnimplementedError();

  @override
  String get path => throw UnimplementedError();

  @override
  final String projectId;

  /// Creates a new [FirebaseRunningEmulator] for the project at [path].
  FirebaseRunningEmulator({required this.projectId});

  @override
  Future<void> stop() async {
    // no-op
  }
}
