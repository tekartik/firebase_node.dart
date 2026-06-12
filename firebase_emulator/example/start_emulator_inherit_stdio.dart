import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

import 'start_emulator.dart';

Future<void> main(List<String> args) async {
  var ideName = shellEnvironment['DASH__IDE_NAME']; // Intellij IDE
  if (ideName != null) {
    // print(ShellEnvironment().vars.toJson().cvToJsonPretty());
    stderr.writeln("Don't call this from IDEA $ideName");
  }

  await service.start(
    options: FirebaseEmulatorOptions(
      persistPath: '.data',
      processStartMode: ProcessStartMode.inheritStdio,
    ),
  );
}
