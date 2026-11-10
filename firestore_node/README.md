# tekartik_firebase_firestore_node

The `tekartik_firebase_firestore` API (`Firestore`, `CollectionReference`,
`DocumentReference`, `Query`, transactions, batches, `onSnapshot`...) on
Node.js, over `firebase-admin/firestore`: Dart compiled to JavaScript
(dart2js) for Cloud Functions, Cloud Run or node scripts, with admin rights.
Code written against the API runs unchanged on the other implementations
(sembast/sdb locally, Flutter, REST). The app comes from
`tekartik_firebase_node` (same repository).

## Getting started

Not on pub.dev, add it as a git dependency (with `tekartik_firebase_node` for
the app):

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

And the npm modules next to `pubspec.yaml` (`npm install`):

```json
{
  "dependencies": {
    "@google-cloud/firestore": "^9.1.0",
    "firebase-admin": "^14.4.0"
  }
}
```

```dart
import 'package:tekartik_firebase_firestore_node/firestore_node.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';

Future<void> main() async {
  // Application default credentials (Cloud Functions, Cloud Run,
  // GOOGLE_APPLICATION_CREDENTIALS).
  var app = firebaseNode.initializeApp();
  var firestore = firestoreServiceNode.firestore(app);
  var ref = await firestore.collection('notes').add({
    'title': 'Hello',
    'created': FieldValue.serverTimestamp,
  });
  var snapshot = await ref.get();
  print('${ref.path}: ${snapshot.data}');
  await ref.delete();
  await app.delete();
}
```

## Platforms

* Node.js only (`dart test -p node`, a dart2js build run by node): reading
  `firestoreServiceNode` loads `firebase-admin/firestore`.
* `package:tekartik_firebase_firestore_node/firestore_universal.dart` gives
  `firestoreService`: `firestoreServiceNode` on node, the in memory sembast
  service on the Dart VM (with `firebaseUniversal` of
  `tekartik_firebase_node`), for a `main` running on both.

## What to know

* Every feature flag of the service is true: query select and cursors,
  `FieldValue` increment and arrays, list collections and documents,
  aggregate queries, vector values, blobs, `onSnapshot`.
* `runTransaction`: firebase-admin may run the update function again
  (contention), keep it idempotent and use only its transaction; an
  exception thrown inside fails the call with that same exception.
* Admin rights: the security rules do not apply.

## Testing

`npm install`, then `dart test -p node` (`-p vm` for the VM tests). The
shared firestore suite runs against a real project with a service account in
`TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT` and a dedicated root collection
in `TEKARTIK_FIRESTORE_NODE_TEST_ROOT_COLLECTION_PATH`; without them it is a
single no-op test. The agent skill
[tekartik-firebase-firestore-node-setup](skills/tekartik-firebase-firestore-node-setup/SKILL.md)
has more examples.
