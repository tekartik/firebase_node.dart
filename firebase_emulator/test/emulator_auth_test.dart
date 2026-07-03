@TestOn('vm')
library;

import 'dart:io';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:test/test.dart';

var _emulatorService = FirebaseEmulatorService(path: 'deploy');
Future main() async {
  var options = FirebaseEmulatorOptions(debug: false, onlyAuth: true);
  if (await _emulatorService.isSupported(options: options)) {
    stdout.writeln('firebase emulator is supported');
  } else {
    test('not_supported', () {}, skip: 'firebase emulator is not supported');
    return;
  }

  group('firebase_functions_dart', () {
    late FirebaseEmulator emulator;
    setUpAll(() async {
      emulator = await _emulatorService.start(options: options);
    });
    test('dummy', () {});
    tearDownAll(() async {
      await emulator.stop();
    });
  }, timeout: const Timeout(Duration(minutes: 5)));
}
