@TestOn('node')
library;

import 'package:tekartik_firebase_auth_node/auth_node_interop.dart';
import 'package:tekartik_firebase_auth_test/auth_test.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var context = await setupOrNull(useEnv: true);

  if (context == null) {
    test('no env set', () {
      // no op
    });
    return;
  }
  if (shouldSkipEnvTestOnGithub()) {
    test('Skip env test on github', () {
      // ignore: avoid_print
      print('githubActionsPrefix: $githubActionsPrefix');
      // ignore: avoid_print
      print('Env test only run by the dedicated env test workflow (linux)');
    });
    return;
  }
  var firebase = firebaseNode;
  var authService = authServiceNode;

  group('auth_node', () {
    runAuthTests(
      firebase: firebase,
      authService: authService,
      options: context.appOptions,
    );
  });
}
