// ignore_for_file: avoid_print

@TestOn('node')
library;

import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_node/src/import_common.dart';
import 'package:tekartik_firebase_node/src/node/firebase_node.dart'
    show AppNode, FirebaseNode;
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

// TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT must be defined in an environment variable
// pointing to the relevant json path
Future<void> main() async {
  var context = await setupOrNull(useEnv: true);

  if (context == null) {
    test('no env set', () {
      // no op
    });
    return;
  }
  if (runningOnGithub && !isGithubActionsUbuntuAndDartStable()) {
    test('Skip on github for other than ubuntu and dart stable', () {
      print('githubActionsPrefix: $githubActionsPrefix');
    });
    return;
  }
  group('node', () {
    test('isLocal', () {
      expect(firebaseNode.isLocal, isFalse);
    });
    runFirebaseTests(firebaseNode, options: context.appOptions);
  });

  group('firebase admin', () {
    test('access token', () async {
      var firebase = firebaseNode as FirebaseNode;
      // print(jsObjectKeys(firebase.nativeInstance));
      // [initializeApp, getApp, getApps, deleteApp, applicationDefault, cert, refreshToken, FirebaseAppError, AppErrorCodes, SDK_VERSION]
      var app =
          firebaseNode.initializeApp(options: context.appOptions, name: 'admin')
              as AppNode;
      expect(app.hasAdminCredentials, isTrue);
      // print(jsObjectKeys(app.nativeInstance!));
      // print(jsObjectGetOwnPropertyNames(app.nativeInstance!));
      // [appStore, services_, isDeleted_, name_, options_, INTERNAL]
      // print(firebase.credential.applicationDefault());
      print(
        (await firebase.credential.applicationDefault()!.getAccessToken()).data,
      );
      print(app.options);
      print(app.options.projectId);
      await app.delete();
    });
  });
}
