---
name: tekartik-firebase-node-setup
description: >-
  Use when running tekartik_firebase code on Node.js (dart2js, dart:js_interop)
  with the firebase-admin sdk through tekartik_firebase_node: firebaseNode
  (FirebaseAdmin), initializeApp with a service account (withServiceAccountMap)
  or the application default credentials, firebaseNode.app(), credential
  access tokens, firebaseUniversal (firebaseNode in JS, FirebaseLocal on the
  VM), the firebase_node.dart / firebase_node_interop.dart /
  firebase_universal.dart / test/setup.dart imports, setupOrNull and
  TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT, shouldSkipEnvTestOnGithub,
  package.json firebase-admin, @TestOn('node') tests, runFirebaseTests and
  firebaseNodePackageJsonTests.
---

# tekartik_firebase_node: the firebase-admin (Node.js) implementation

`tekartik_firebase_node` implements the `tekartik_firebase` abstractions
(`Firebase`, `FirebaseAdmin`, `FirebaseApp`, `FirebaseAppOptions`) on top of
the `firebase-admin` npm module through `dart:js_interop`. It is the base of
the other firebase `*_node` packages (`tekartik_firebase_auth_node`,
`tekartik_firebase_firestore_node`, `tekartik_firebase_storage_node`,
`tekartik_firebase_functions_node`): they all take the `FirebaseApp` created
here. Its code only runs when compiled to JavaScript for Node.js (cloud
functions, node scripts, `dart test -p node`); on the VM `firebaseUniversal`
falls back to `FirebaseLocal`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_firebase_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_node
  dev_dependencies:
    build_runner: '>=2.15.0'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
    tekartik_firebase_node_test:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_node_test
  ```
  It brings `tekartik_firebase` (the abstractions) and `tekartik_firebase_local`
  (the VM fallback). The npm side: a `package.json` next to `pubspec.yaml`
  with `"firebase-admin": "^14.4.0"` (the minimum enforced by
  `tekartik_firebase_node_test`), then `npm install`. `dart_test.yaml`:
  `platforms: [node, vm]` (or `[node]` for a node-only package).
* Imports:
  - `package:tekartik_firebase_node/firebase_node.dart` re-exports
    `package:tekartik_firebase/firebase.dart` and adds `firebaseNode` and the
    `debugFirebaseNode` flag.
  - `package:tekartik_firebase_node/firebase_node_interop.dart`: `firebaseNode`
    plus the `FirebaseNodeAppOptionsExt.withServiceAccountMap` extension on
    `FirebaseAppOptions` (only here, `firebase_node.dart` does not export it).
  - `package:tekartik_firebase_node/firebase_universal.dart` re-exports the
    abstractions and adds `firebaseUniversal` (also named `firebase`):
    `firebaseNode` when compiled to JS, a `FirebaseLocal()` on the VM, an
    `UnsupportedError` elsewhere (browser).
  - `package:tekartik_firebase_node/impl/firebase_node.dart`: the
    `FirebaseNode` and `AppNode` (`FirebaseAppNode`) classes, whose
    `nativeInstance` is the raw `firebase-admin` object, for js interop code.
  - `package:tekartik_firebase_node/firebase_node_js_interop.dart`:
    `firebaseRequire<T>(module)` (a `require` logged when `debugFirebaseNode`
    is true) and the js `App` extension type.
  - `package:tekartik_firebase_node/test/setup.dart`: the test helpers
    (`setup`, `setupOrNull`, `FirebaseNodeTestContext`, `runningOnGithub`,
    `shouldSkipEnvTestOnGithub`, `isGithubActionsEnvTest`,
    `githubActionsPrefix`).
  - The `*_legacy.dart` libraries are deprecated aliases of the above.
* `firebaseNode` is a lazily created `FirebaseAdmin` singleton over
  `firebase-admin/app` (loaded with `require` at first access, so merely
  touching it on the VM throws).
* `firebaseNode.initializeApp(options:, name:)`:
  - no `options`: the `[DEFAULT]` app with the Google application default
    credentials of the runtime (Cloud Functions, Cloud Run,
    `GOOGLE_APPLICATION_CREDENTIALS`); `name` is ignored in that case.
  - `FirebaseAppOptions(projectId:, storageBucket:, databaseURL:)`: same
    credentials, explicit project; the other fields (`apiKey`, `appId`...) are
    not forwarded to node.
  - a service account: `FirebaseAppOptions().withServiceAccountMap(map)` where
    `map` is the decoded service account json (`project_id`, `client_email`
    and `private_key` are read from it, `storageBucket` defaults to
    `<project_id>.appspot.com`, pass `FirebaseAppOptions(storageBucket: ...)`
    to override). `FirebaseNodeTestContext.appOptions` builds it from the
    test environment.
  - initializing the same name twice throws; get an existing app with
    `firebaseNode.app(name:)` (`[DEFAULT]` when omitted, throws when it was
    never initialized).
* `app.hasAdminCredentials` is `true`, `app.isLocal` and
  `firebaseNode.isLocal` are `false`. `app.options` gives back `projectId`,
  `storageBucket` and `databaseURL` only. `await app.delete()` closes the
  product services attached to the app (firestore, auth...) then the native
  app.
* `firebaseNode.credential.applicationDefault()` returns a
  `FirebaseAdminCredential`; `await credential.getAccessToken()` gives `data`
  (the OAuth2 token) and `expiresIn` (seconds). `setApplicationDefault` throws
  `UnsupportedError` on node. Never print a token or a private key.
* Products: hand the app to the node services of the sibling packages,
  `authServiceNode.auth(app)`, `firestoreServiceNode.firestore(app)`,
  `storageServiceNode.storage(app)`; they assert the app is an `AppNode`, so a
  `FirebaseLocal` app cannot be mixed in.
* Platform split: write shared code against `Firebase` / `FirebaseApp` and
  pick `firebaseNode` in the node entry point (`bin/main.dart` compiled with
  dart2js, `@TestOn('node')` tests). A `main` that must run both as a node app
  and on the VM uses `firebaseUniversal` (`initializeApp()` works on both,
  `FirebaseLocal` defaults to the project id `local`).
* Tests: `dart test -p node` (node on the path, `npm install` done). Tests
  needing a real project read `TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT`
  (the service account json itself, starting with `{`, or the path of the
  file) through `setupOrNull(useEnv: true)`: `null` means not configured,
  declare a placeholder test and return. Set it locally in
  `.local/ds_env.yaml` (`var:` section, the `process_run` user config). On
  github the env tests only run in the dedicated workflow: guard them with
  `shouldSkipEnvTestOnGithub()`. `setupOrNull(useEnv: true, verbose: true)`
  prints each setup step (never the private key).
* Shared suites: `runFirebaseTests(firebaseNode, options: context.appOptions)`
  from `package:tekartik_firebase_test/firebase_test.dart`;
  `firebaseNodePackageJsonTests(requiredDependencies:
  [firebaseAdminNpmPackageName])` from
  `package:tekartik_firebase_node_test/firebase_node_test.dart` (`@TestOn('vm')`)
  checks `package.json` against `firebaseNodeNpmMinConstraints` and that
  `node_modules` is up to date.
* `tool/run_ci.dart`: `nodePackageRunCi('.')` from
  `package:tekartik_app_node_build/package.dart` (npm install, analyze, vm and
  node tests); `nodePackageRunTest('.', testFiles: [...])` from
  `package:tekartik_build_node/build_node.dart` runs one node test file.
* `debugFirebaseNode = true` (do-not-submit) prints every module loaded
  through `firebaseRequire`.

## Examples

### Node script with a service account from the environment

```dart
import 'dart:convert';

import 'package:tekartik_firebase_node/firebase_node.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_platform_node/context_universal.dart';

/// Compiled with dart2js and run with node; SERVICE_ACCOUNT_JSON holds the
/// service account json.
Future<void> main() async {
  var serviceAccountMap =
      (jsonDecode(platform.environment['SERVICE_ACCOUNT_JSON']!) as Map)
          .cast<String, Object?>();
  var app = firebaseNode.initializeApp(
    options: FirebaseAppOptions().withServiceAccountMap(serviceAccountMap),
    name: 'script',
  );
  print('project ${app.options.projectId}, admin ${app.hasAdminCredentials}');
  // authServiceNode.auth(app), firestoreServiceNode.firestore(app)...
  await app.delete();
}
```

### Default app with the application default credentials

```dart
import 'package:tekartik_firebase_node/firebase_node.dart';

/// On Cloud Functions / Cloud Run, or with GOOGLE_APPLICATION_CREDENTIALS set.
FirebaseApp initDefaultApp() {
  firebaseNode.initializeApp(); // the `[DEFAULT]` app, no name
  return firebaseNode.app();
}

Future<void> printAccessTokenInfo() async {
  var credential = firebaseNode.credential.applicationDefault()!;
  var token = await credential.getAccessToken();
  // never print token.data itself
  print('token: ${token.data.length} chars, expires in ${token.expiresIn} s');
}
```

### Same main on node and on the VM

```dart
import 'package:tekartik_firebase_node/firebase_universal.dart';

Future<void> main() async {
  // firebaseNode when compiled to JS, FirebaseLocal on the VM.
  var app = firebaseUniversal.initializeApp();
  print('${app.name} local: ${app.isLocal} project: ${app.options.projectId}');
  await app.delete();
}
```

### Node test against the configured project

```dart
@TestOn('node')
library;

import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  // TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT: json or path
  var context = await setupOrNull(useEnv: true);
  if (context == null) {
    test('no env set', () {});
    return;
  }
  if (shouldSkipEnvTestOnGithub()) {
    test('env test skipped on github ($githubActionsPrefix)', () {});
    return;
  }
  group('node', () {
    test('admin app', () async {
      var app = firebaseNode.initializeApp(
        options: context.appOptions,
        name: 'test',
      );
      expect(app.hasAdminCredentials, isTrue);
      expect(app.options.projectId, context.projectId);
      await app.delete();
    });
    runFirebaseTests(firebaseNode, options: context.appOptions);
  });
}
```

### package.json check (VM) and tool/run_ci.dart

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  // package.json exists, firebase-admin >= ^14.4.0, node_modules up to date
  firebaseNodePackageJsonTests(
    requiredDependencies: [firebaseAdminNpmPackageName],
  );
}
```

```dart
import 'package:tekartik_app_node_build/package.dart';

Future<void> main() async {
  await nodePackageRunCi('.');
}
```

## Common mistakes

* Touching `firebaseNode` in code that runs on the VM: use `firebaseUniversal`
  or keep the access in a `@TestOn('node')` file / dart2js entry point.
* Importing only `firebase_node.dart` and expecting `withServiceAccountMap`:
  it comes from `firebase_node_interop.dart`.
* Passing a `FirebaseLocal` app to `authServiceNode` / `firestoreServiceNode`.
* Forgetting `npm install` (or `package.json`) before `dart test -p node`.
* Printing tokens or the service account private key in test output.
