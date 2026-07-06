import 'dart:io';

import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

var service = FirebaseEmulatorService(path: 'deploy');

Future<void> main(List<String> args) async {
  var status = await service.checkStatus(verbose: true);
  stdout.writeln('Status: $status');
}
