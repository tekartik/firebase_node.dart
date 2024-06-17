@TestOn('node')
library;

import 'package:tekartik_firebase_firestore_node/firestore_node_interop.dart';
import 'package:tekartik_firebase_firestore_node/src/node/common_import.dart';
import 'package:tekartik_firebase_firestore_test/firestore_test.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

var _env = platformContextNode.node!.environment;

Future<void> main() async {
  var context = await setupOrNull(useEnv: true);

  if (context == null) {
    test('no env set', () {
      // no op
    });
    return;
  }
  var rootCollectionPath =
      _env['TEKARTIK_FIRESTORE_NODE_TEST_ROOT_COLLECTION_PATH'];
  test('app', () {
    print(
        'TEKARTIK_FIRESTORE_NODE_TEST_ROOT_COLLECTION_PATH: $rootCollectionPath');
    // devPrint('Using firebase project: ${context.serviceAccount}');
  });

  if (rootCollectionPath != null) {
    // Temp skipping transaction test
    skipConcurrentTransactionTests = true;

    var firebase = firebaseNode;
    runFirestoreTests(
        firebase: firebase,
        firestoreService: firestoreServiceNode,
        options: context.appOptions,
        testContext:
            FirestoreTestContext(rootCollectionPath: rootCollectionPath));
  }
}
