// ignore_for_file: avoid_print

/// Node entry point of `tool/setup_io_env_verbose.dart`.
library;

import 'package:tekartik_firebase_node/test/setup.dart';

Future<void> main() async {
  var context = await setupOrNull(useEnv: true, verbose: true);
  if (context == null) {
    print('No context (see the error above)');
    return;
  }
  print('context: $context');
  print('  project id: ${context.projectId}');
  print('  client email: ${context.clientEmail}');
  print('  app options project id: ${context.appOptions.projectId}');
  print('  app options storage bucket: ${context.appOptions.storageBucket}');
}
