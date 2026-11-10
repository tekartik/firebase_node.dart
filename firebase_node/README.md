# tekartik_firebase_node

The `tekartik_firebase` app API (`Firebase`, `FirebaseAdmin`, `FirebaseApp`)
on Node.js, over the `firebase-admin` npm module: Dart compiled to
JavaScript (dart2js) for Cloud Functions, Cloud Run or node scripts. The
products take the app created here: `tekartik_firebase_firestore_node`,
`tekartik_firebase_auth_node`, `tekartik_firebase_storage_node`,
`tekartik_firebase_functions_node` (same repository).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_firebase_node:
    git:
      url: https://github.com/tekartik/firebase_node.dart
      path: firebase_node
```

And the npm module next to `pubspec.yaml` (deployed with the compiled js):

```json
{
  "dependencies": {
    "firebase-admin": "^14.4.0"
  }
}
```

```dart
import 'dart:convert';

import 'package:tekartik_firebase_node/firebase_node.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';

/// [serviceAccountJson]: the content of a service account key file.
Future<void> printProject(String serviceAccountJson) async {
  var serviceAccount = (jsonDecode(serviceAccountJson) as Map)
      .cast<String, Object?>();
  var app = firebaseNode.initializeApp(
    options: FirebaseAppOptions().withServiceAccountMap(serviceAccount),
    name: 'script',
  );
  print('project: ${app.options.projectId}');
  // firestoreServiceNode.firestore(app), authServiceNode.auth(app)...
  await app.delete();
}

/// On Cloud Functions / Cloud Run (application default credentials).
FirebaseApp initDefaultApp() => firebaseNode.initializeApp();
```

## Libraries and platforms

* `package:tekartik_firebase_node/firebase_node.dart`: the
  `tekartik_firebase` API plus `firebaseNode`. Node.js only (reading
  `firebaseNode` loads `firebase-admin/app` with `require`).
* `package:tekartik_firebase_node/firebase_node_interop.dart`:
  `firebaseNode` and the `withServiceAccountMap` extension on
  `FirebaseAppOptions`.
* `package:tekartik_firebase_node/firebase_universal.dart`:
  `firebaseUniversal`: `firebaseNode` on node, `FirebaseLocal` (local files,
  no server) on the Dart VM, for a `main` that runs on both.
* `package:tekartik_firebase_node/test/setup.dart`: test helpers reading a
  service account from `TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT` (the
  json itself or a file path).

## Testing

`npm install`, then `dart test -p node` (and `-p vm` for the VM tests). The
tests reaching a real project need
`TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT`; without it they are a single
no-op test.

## Common pitfalls

* No `options`: the `[DEFAULT]` app with the application default
  credentials of the runtime; a `name` given without `options` is ignored.
* A service account app gets `<project_id>.appspot.com` as its default
  storage bucket. Projects created since October 2024 use
  `<project_id>.firebasestorage.app`: pass it,
  `FirebaseAppOptions(storageBucket: ...).withServiceAccountMap(map)`.
* Print `app.options`, not the options built by `withServiceAccountMap`
  (they hold the private key; their `toDebugMap()` throws).
* `firebaseNode` on the VM or in a browser fails: use `firebaseUniversal`
  in shared code, or keep the access in node entry points and
  `@TestOn('node')` tests.
* Initializing the same app name twice throws; get it back with
  `firebaseNode.app(name: ...)`. `await app.delete()` closes its products.
* Never print a service account private key nor an access token.
