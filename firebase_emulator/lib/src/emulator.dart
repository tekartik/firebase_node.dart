import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:meta/meta.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

class FirebaseEmulator {
  final String path;
  final FirebaseEmulatorOptions options;
  final Shell _shell;
  final Future _done;

  FirebaseEmulator._({
    required this.path,
    required this.options,
    required Shell shell,
    required Future done,
  }) : _shell = shell,
       _done = done;

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
}) async {
  return FirebaseEmulator._(
    path: path,
    options: options,
    shell: shell,
    done: done,
  );
}
