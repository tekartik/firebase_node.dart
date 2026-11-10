// Starts the emulators of deploy/ in the foreground until Ctrl+C.
//
// The cli output is echoed, not inherited: `FirebaseEmulatorService.start`
// reads its `All emulators ready` line, a
// `processStartMode: ProcessStartMode.inheritStdio` would hide it from
// `start`, which would then time out and kill the cli.
import 'dart:io';

import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

import 'start_emulator.dart';

Future<void> main(List<String> args) async {
  var emulator = await service.start(
    options: FirebaseEmulatorOptions(persistPath: '.data'),
  );
  stdout.writeln('Emulator started, Ctrl+C to stop it');
  await ProcessSignal.sigint.watch().first;
  // Exports .data, then releases the emulator lock.
  await emulator.stop();
  stdout.writeln('Emulator stopped');
}
