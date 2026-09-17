// ignore_for_file: avoid_print

@TestOn('node')
library;

import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:test/test.dart';

/// Checks the env setup (TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT) in
/// verbose mode, each step being printed.
///
/// See `tool/setup_io_env_verbose.dart` for the tool version.
Future<void> main() async {
  var context = await setupOrNull(useEnv: true, verbose: true);

  if (context == null) {
    test('no env set', () {
      // no op
    });
    return;
  }
  if (shouldSkipEnvTestOnGithub()) {
    test('Skip env test on github', () {
      print('githubActionsPrefix: $githubActionsPrefix');
      print('Env test only run by the dedicated env test workflow (linux)');
    });
    return;
  }
  group('setup_env', () {
    test('context', () {
      print('context: $context');
      expect(context.serviceAccount['type'], 'service_account');
      expect(context.projectId, isNotEmpty);
      expect(context.clientEmail, contains('@'));
      // Never printed by the verbose setup.
      expect(context.serviceAccount.keys, contains('private_key'));
    });
    test('appOptions', () {
      var appOptions = context.appOptions;
      print(
        'appOptions: projectId ${appOptions.projectId}, '
        'storageBucket ${appOptions.storageBucket}',
      );
      expect(appOptions.projectId, context.projectId);
    });
    test('verbose', () async {
      var verboseContext = await setupOrNull(useEnv: true, verbose: true);
      expect(verboseContext!.projectId, context.projectId);
    });
  });
}
