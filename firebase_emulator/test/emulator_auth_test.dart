@TestOn('vm')
library;

import 'dart:io';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:test/test.dart';

var _emulatorService = FirebaseEmulatorService(path: 'deploy');
Future main() async {
  if (await _emulatorService.isSupported()) {
    stdout.writeln('firebase emulator is supported');
  } else {
    test('not_supported', () {}, skip: 'firebase emulator is not supported');
    return;
  }
  final fbProjectId = await _emulatorService.getProjectId();
  group('firebase_functions_dart', () {
    late FirebaseEmulator emulator;
    setUpAll(() async {
      emulator = await _emulatorService.start(
        options: FirebaseEmulatorOptions(
          projectId: fbProjectId,
          debug: false,
          onlyAuth: true,
        ),
      );
    });
    test('dummy', () {});
    tearDownAll(() async {
      await emulator.stop();
    });
  }, timeout: const Timeout(Duration(minutes: 5)));
}
