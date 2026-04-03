import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

Future<void> main(List<String> args) async {
  var service = FirebaseEmulatorService(path: 'deploy');

  var emulator = await service.start();
  stdout.writeln('Emulator started');
  await prompt('Press enter to stop the emulator');
  await emulator.stop();
  stdout.writeln('Emulator stopped');
  await promptTerminate();
}
