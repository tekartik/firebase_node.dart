@TestOn('node')
library;

import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_node/src/node/firebase_node.dart'
    show AppNode, FirebaseNode;
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

var _env = platformContextNode.node!.environment;
// GOOGLE_APPLICATION_CREDENTIALS must be defined in an environment variable
// pointing to the relevant json path
void main() {
  /*
  group('node', () {
    // there is no name on node
    runApp(firebaseNode, options: null);
  });
   */
  group('firebase admin', () {
    /*
    test('app', () {
      print('FIREBASE_CONFIG: ${_env['FIREBASE_CONFIG']}');
      print(
          'GOOGLE_APPLICATION_CREDENTIALS: ${_env['GOOGLE_APPLICATION_CREDENTIALS']}');
    });*/
    test('access token', () async {
      var firebase = firebaseNode as FirebaseNode;
      // print(jsObjectKeys(firebase.nativeInstance));
      // [initializeApp, getApp, getApps, deleteApp, applicationDefault, cert, refreshToken, FirebaseAppError, AppErrorCodes, SDK_VERSION]
      var app = firebaseNode.initializeApp(name: 'admin') as AppNode;
      // print(jsObjectKeys(app.nativeInstance!));
      // print(jsObjectGetOwnPropertyNames(app.nativeInstance!));
      // [appStore, services_, isDeleted_, name_, options_, INTERNAL]
      // print(firebase.credential.applicationDefault());
      print((await firebase.credential.applicationDefault()!.getAccessToken())
          .data);
      print(app.options);
      print(app.options.projectId);
      await app.delete();
    });
  }, skip: _env['FIREBASE_CONFIG'] == null ? 'no FIREBASE_CONFIG' : null);
}
