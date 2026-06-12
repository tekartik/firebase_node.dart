import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

var service = FirebaseEmulatorService(path: 'deploy');

Future<void> main(List<String> args) async {
  var emulator = await service.start(
    options: FirebaseEmulatorOptions(persistPath: '.data'),
  );
  stdout.writeln('Emulator started');
  await prompt('Press enter to stop the emulator');
  await emulator.stop();
  stdout.writeln('Emulator stopped');
  await promptTerminate();
}
