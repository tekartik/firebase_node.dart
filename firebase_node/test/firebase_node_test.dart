@TestOn('node')
library tekartik_firebase_server_node.node_test;

import 'package:tekartik_firebase_node/firebase_node.dart';
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
    test('app', () {
      print('FIREBASE_CONFIG: ${_env['FIREBASE_CONFIG']}');
      print(
          'GOOGLE_APPLICATION_CREDENTIALS: ${_env['GOOGLE_APPLICATION_CREDENTIALS']}');
    });
    if (_env['FIREBASE_CONFIG'] != null) {
      test('access token', () async {
        var app = await firebaseNode.initializeAppAsync(name: 'admin');
        print((await firebaseNode.credential
                .applicationDefault()!
                .getAccessToken())
            .data);
        print(app.options);
        print(app.options.projectId);
        await app.delete();
      });
    }
  });
}
