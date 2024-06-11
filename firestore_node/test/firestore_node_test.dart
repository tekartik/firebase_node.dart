@TestOn('node')
library;

import 'package:tekartik_firebase_firestore_node/firestore_node_interop.dart';
import 'package:tekartik_firebase_firestore_test/firestore_test.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

var _env = platformContextNode.node!.environment;

void main() {
  test('app', () {
    print('FIREBASE_CONFIG: ${_env['FIREBASE_CONFIG']}');
    print(
        'GOOGLE_APPLICATION_CREDENTIALS: ${_env['GOOGLE_APPLICATION_CREDENTIALS']}');
  });
  if (_env['FIREBASE_CONFIG'] != null) {
    // Temp skipping transaction test
    skipConcurrentTransactionTests = true;

    var firebase = firebaseNode;
    run(firebase: firebase, firestoreService: firestoreServiceNode);
  }
}
