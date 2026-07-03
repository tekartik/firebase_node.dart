import 'dart:io';
import 'package:dev_build/shell.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

var _emulatorService = FirebaseEmulatorService(path: 'deploy');
Future main() async {
  var status = await _emulatorService.checkStatus();
  if (!status.supported) {
    stdout.writeln('firebase emulator is not supported (status: $status)');
    return;
  } else {
    stderr.writeln('firebase emulator supported');
  }

  var options = FirebaseEmulatorOptions(
    onlyFirestore: true,
    debug: false,
    persistPath: '.data',
  );
  var emulator = await _emulatorService.start(options: options);

  stdout.writeln('Emulator started');
  await prompt('Press enter to stop the emulator');
  await emulator.stop();
  stdout.writeln('Emulator stopped');
  await promptTerminate();
}
