---
name: tekartik-firebase-firestore-node-setup
description: >-
  Use when reading or writing Cloud Firestore from Node.js (dart2js,
  firebase-admin and @google-cloud/firestore) with
  tekartik_firebase_firestore_node: firestoreServiceNode,
  firestoreServiceNode.firestore(app) on a firebaseNode app, the
  firestore_node.dart / firestore_node_interop.dart / firestore_universal.dart
  imports (firestoreService: node in JS, the sembast in-memory service on the
  VM), the supported features (transactions, batches, getAll, onSnapshot,
  aggregate queries, vector values, blobs, list collections), package.json
  @google-cloud/firestore, and running the shared runFirestoreTests suite on
  node with TEKARTIK_FIRESTORE_NODE_TEST_ROOT_COLLECTION_PATH.
---

# tekartik_firebase_firestore_node: Firestore admin access on Node.js

`tekartik_firebase_firestore_node` implements `tekartik_firebase_firestore`
(`FirestoreService`, `Firestore`, `CollectionReference`, `DocumentReference`,
`Query`, `WriteBatch`, `Transaction`, `DocumentSnapshot`...) over
`firebase-admin/firestore` and `@google-cloud/firestore` through
`dart:js_interop`. The dart api is the one shared with
`tekartik_firebase_firestore_sembast` (local) and the flutter implementation;
only the service getter differs, so firestore code stays platform neutral.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_firebase_firestore_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firestore_node
    tekartik_firebase_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_node
  ```
  It brings `tekartik_firebase_firestore` (the api) and
  `tekartik_firebase_firestore_sembast` (the VM fallback). npm: `package.json`
  with `"firebase-admin": "^14.4.0"` and `"@google-cloud/firestore": "^9.1.0"`
  (both checked by `firebaseNodePackageJsonTests`), then `npm install`.
* Imports:
  - `package:tekartik_firebase_firestore_node/firestore_node.dart` re-exports
    `package:tekartik_firebase_firestore/firestore.dart` (and through it
    `tekartik_firebase`) and adds `firestoreServiceNode`.
  - `package:tekartik_firebase_firestore_node/firestore_node_interop.dart`:
    `firestoreServiceNode` only.
  - `package:tekartik_firebase_firestore_node/firestore_universal.dart`
    re-exports the api and adds `firestoreService`: `firestoreServiceNode`
    when compiled to JS, `firestoreServiceMemory` (sembast, in memory) on the
    VM, an `UnsupportedError` elsewhere. Pair it with `firebaseUniversal` from
    `package:tekartik_firebase_node/firebase_universal.dart`.
* `firestoreServiceNode.firestore(app)` returns the `Firestore` of a
  `firebaseNode` app (one cached instance per app; asserts the app is an
  `AppNode`). Initialize the app first (service account or default
  credentials, see the `tekartik-firebase-node-setup` skill); in a cloud
  function, `firebaseNode.initializeApp()` once then
  `firestoreServiceNode.firestore(firebaseNode.app())`.
* Every capability flag of the service is `true`: `supportsQuerySelect`,
  `supportsDocumentSnapshotTime`, `supportsTimestamps`,
  `supportsTimestampsInSnapshots`, `supportsQuerySnapshotCursor`,
  `supportsFieldValueArray`, `supportsTrackChanges` (`onSnapshot` streams),
  `supportsListCollections`, `supportsAggregateQueries`,
  `supportsVectorValue`, `supportsBlobs`. Code written for the abstraction
  (`collection`, `doc`, `add`, `set` with `SetOptions(merge: true)`, `update`,
  `get`, `where`/`orderBy`/`limit`, `runTransaction`, `batch`, `getAll`)
  works unchanged.
* Values round-trip both ways: `Timestamp`, `GeoPoint`, `Blob`, `VectorValue`,
  `DocumentReference`, nested lists and maps, `FieldValue.serverTimestamp`,
  `FieldValue.delete` and the array field values.
* `firestore.runTransaction((txn) async { ... })` runs the native transaction
  (the callback may be retried, keep it idempotent and use only `txn`
  inside). `firestore.batch()` groups writes, `batch.commit()` sends them.
* `firestore.settings(FirestoreSettings(...))` only forwards the deprecated
  `timestampsInSnapshots` flag; there is no need to call it.
* Tests: node only (`@TestOn('node')`), `dart test -p node`, with
  `concurrency: 1` in `dart_test.yaml` (one process on the project at a
  time). The shared suite is `runFirestoreTests(firebase: firebaseNode,
  firestoreService: firestoreServiceNode, options: context.appOptions,
  testContext: FirestoreTestContext(rootCollectionPath: ...))` from
  `package:tekartik_firebase_firestore_test/firestore_test.dart`; the root
  path comes from `TEKARTIK_FIRESTORE_NODE_TEST_ROOT_COLLECTION_PATH` (read
  with `platformContextNode.node!.environment` from
  `package:tekartik_platform_node/context_node.dart`) so the tests write under
  a dedicated collection, and the service account from
  `TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT` through
  `setupOrNull(useEnv: true)` (`package:tekartik_firebase_node/test/setup.dart`).
  Both go in `.local/ds_env.yaml` locally. `skipConcurrentTransactionTests =
  true` disables the concurrent transaction tests when the project is slow.
* VM tests of your own firestore code use `firestoreServiceMemory` with
  `newFirebaseAppLocal()`; the node package is only needed for the real
  project.

## Examples

### Write, read and query from a node script

```dart
import 'package:tekartik_firebase_firestore_node/firestore_node.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';

Future<void> main() async {
  // Default credentials (cloud function, GOOGLE_APPLICATION_CREDENTIALS)
  var app = firebaseNode.initializeApp();
  var firestore = firestoreServiceNode.firestore(app);

  var notes = firestore.collection('notes');
  var ref = await notes.add({
    'title': 'Hello',
    'created': FieldValue.serverTimestamp,
    'tags': ['a', 'b'],
  });
  await ref.update({'title': 'Hello world'});

  var snapshot = await ref.get();
  print('${snapshot.ref.path} exists: ${snapshot.exists} ${snapshot.data}');

  var query = await notes
      .where('title', isEqualTo: 'Hello world')
      .orderBy('created', descending: true)
      .limit(10)
      .get();
  for (var doc in query.docs) {
    print('${doc.ref.id}: ${doc.data['created'] as Timestamp?}');
  }
  await ref.delete();
  await app.delete();
}
```

### Transaction and batch (platform neutral, takes a Firestore)

```dart
import 'package:tekartik_firebase_firestore_node/firestore_node.dart';

Future<void> incrementCounter(Firestore firestore, String path) async {
  var ref = firestore.doc(path);
  await firestore.runTransaction((txn) async {
    var snapshot = await txn.get(ref);
    var count = snapshot.exists ? (snapshot.data['count'] as int? ?? 0) : 0;
    txn.set(ref, {'count': count + 1, 'updated': FieldValue.serverTimestamp});
  });
}

Future<void> deleteAll(Firestore firestore, String collectionPath) async {
  var docs = (await firestore.collection(collectionPath).get()).docs;
  var batch = firestore.batch();
  for (var doc in docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
}
```

### Same main on node (firebase-admin) and on the VM (memory)

```dart
import 'package:tekartik_firebase_firestore_node/firestore_universal.dart';
import 'package:tekartik_firebase_node/firebase_universal.dart';

Future<void> main() async {
  var app = firebaseUniversal.initializeApp();
  var firestore = firestoreService.firestore(app);
  var ref = firestore.doc('settings/main');
  await ref.set({'version': 1}, SetOptions(merge: true));
  print((await ref.get()).data);
  await app.delete();
}
```

### Node test running the shared firestore suite

```dart
@TestOn('node')
library;

import 'package:tekartik_firebase_firestore_node/firestore_node_interop.dart';
import 'package:tekartik_firebase_firestore_test/firestore_test.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:tekartik_platform_node/context_node.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var context = await setupOrNull(useEnv: true);
  if (context == null || shouldSkipEnvTestOnGithub()) {
    test('no env set', () {});
    return;
  }
  var rootCollectionPath = platformContextNode
      .node!
      .environment['TEKARTIK_FIRESTORE_NODE_TEST_ROOT_COLLECTION_PATH'];
  if (rootCollectionPath == null) {
    test('no root collection path set', () {});
    return;
  }
  test('supports', () {
    expect(firestoreServiceNode.supportsVectorValue, isTrue);
  });
  runFirestoreTests(
    firebase: firebaseNode,
    firestoreService: firestoreServiceNode,
    options: context.appOptions,
    testContext: FirestoreTestContext(rootCollectionPath: rootCollectionPath),
  );
}
```

### package.json check (VM)

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  firebaseNodePackageJsonTests(
    requiredDependencies: [
      firebaseAdminNpmPackageName,
      googleCloudFirestoreNpmPackageName,
    ],
  );
}
```

## Common mistakes

* Using `firestore` (or `db`) inside `runTransaction` instead of `txn`.
* Passing a `FirebaseLocal` app to `firestoreServiceNode.firestore`: on the VM
  use `firestoreService` from `firestore_universal.dart` (memory) or the
  sembast service directly.
* Running the node tests against a project without a dedicated root
  collection path: the suite creates and deletes documents under it.
* Missing `@google-cloud/firestore` in `package.json` (`firebase-admin` alone
  is not enough for the firestore module).
