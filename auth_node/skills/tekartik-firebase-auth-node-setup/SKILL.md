---
name: tekartik-firebase-auth-node-setup
description: >-
  Use when managing Firebase Authentication users from Node.js (dart2js,
  firebase-admin) with tekartik_firebase_auth_node: authServiceNode,
  authServiceNode.auth(app) on a firebaseNode app, listUsers and pageToken,
  getUser, getUserByEmail, UserRecord, verifyIdToken and DecodedIdToken, what
  is not supported server side (currentUser, sign in), the auth_node.dart /
  auth_node_interop.dart / auth_universal.dart imports (authService:
  authServiceNode in JS, authServiceLocal on the VM), package.json
  firebase-admin and running the shared runAuthTests suite on node.
---

# tekartik_firebase_auth_node: firebase-admin auth on Node.js

`tekartik_firebase_auth_node` implements the admin side of the
`tekartik_firebase_auth` api (`FirebaseAuthService` / `FirebaseAuth`,
`UserRecord`, `ListUsersResult`, `DecodedIdToken`) over `firebase-admin/auth`
through `dart:js_interop`, for dart code compiled to JavaScript and run with
node: cloud functions, admin scripts, `dart test -p node`. The `FirebaseApp`
comes from `tekartik_firebase_node`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_firebase_auth_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: auth_node
    tekartik_firebase_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_node
  ```
  It brings `tekartik_firebase_auth` (the api) and
  `tekartik_firebase_auth_local` (the VM fallback). npm: `package.json` with
  `"firebase-admin": "^14.4.0"`, then `npm install`.
* Imports:
  - `package:tekartik_firebase_auth_node/auth_node.dart` re-exports
    `package:tekartik_firebase_auth/auth.dart` (`AuthService`, `Auth`,
    `UserRecord`, `UserInfo`, `UserMetadata`, `ListUsersResult`,
    `DecodedIdToken`, plus `tekartik_firebase`) and adds `authServiceNode`
    (and the deprecated `authService` alias of it).
  - `package:tekartik_firebase_auth_node/auth_node_interop.dart`:
    `authServiceNode` only.
  - `package:tekartik_firebase_auth_node/auth_universal.dart` re-exports the
    api and adds `authService`: `authServiceNode` when compiled to JS,
    `authServiceLocal` (`tekartik_firebase_auth_local`, in memory) on the VM,
    an `UnsupportedError` elsewhere. Pair it with `firebaseUniversal` from
    `package:tekartik_firebase_node/firebase_universal.dart`. Do not import it
    together with `auth_node.dart` (both declare `authService`).
* `authServiceNode.auth(app)` returns the `Auth` of a `firebaseNode` app (one
  cached instance per app; asserts the app is an `AppNode`). Initialize the
  app first, with a service account or the default credentials (see the
  `tekartik-firebase-node-setup` skill); in a cloud function use
  `firebaseNode.app()` after a single `firebaseNode.initializeApp()`.
* Admin api implemented: `listUsers({maxResults, pageToken})` returning a
  `ListUsersResult` (`users`, a `List<UserRecord?>`, and `pageToken` to pass to
  the next call, loop while it is a non-empty string);
  `getUser(uid)`, `getUserByEmail(email)` returning a `UserRecord`;
  `verifyIdToken(idToken, checkRevoked:)` returning a `DecodedIdToken` (only
  `uid` is exposed). `supportsListUsers` is `true`. A missing user makes
  firebase-admin reject (`auth/user-not-found`): the call throws instead of
  returning `null`, catch it.
* `UserRecord` fields: `uid`, `email`, `emailVerified`, `displayName`,
  `photoURL`, `phoneNumber`, `disabled`, `customClaims` (raw js object),
  `metadata` (`creationTime`; `lastSignInTime` currently mirrors
  `creationTime`), `providerData` (`UserInfo` list: `providerId`, `uid`,
  `email`...), `passwordHash`, `passwordSalt`, `tokensValidAfterTime` (only
  filled for records coming from `listUsers`). `toString()` dumps the record
  for debugging.
* Not available server side: `supportsCurrentUser` is `false`;
  `currentUser`, `onCurrentUser` and `reloadCurrentUser` throw
  `UnsupportedError`; `signInWithEmailAndPassword`, `signInAnonymously`,
  `signOut`, `createUserWithEmailAndPassword`, `getUsers`,
  `sendEmailVerification` and `sendPasswordResetEmail` throw the mixin
  `UnsupportedError` / `UnimplementedError`. The js bindings for
  `createUser`, `updateUser`, `deleteUser`, `setCustomUserClaims` exist in
  `lib/src/node/auth_node_js_interop.dart` but are not wrapped by the public
  api.
* Verifying a client in an https function: read the `Authorization: Bearer
  <idToken>` header, `await auth.verifyIdToken(token)`, use `decoded.uid`;
  an invalid or expired token rejects, catch it and answer 401.
* Tests: `@TestOn('node')`, `dart test -p node`. The shared suite is
  `runAuthTests(firebase: firebaseNode, authService: authServiceNode,
  options: context.appOptions)` from
  `package:tekartik_firebase_auth_test/auth_test.dart`, guarded by
  `setupOrNull(useEnv: true)` (`TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT`)
  and `shouldSkipEnvTestOnGithub()` from
  `package:tekartik_firebase_node/test/setup.dart`. On the VM,
  `firebaseNodePackageJsonTests(requiredDependencies:
  [firebaseAdminNpmPackageName])` (`tekartik_firebase_node_test`) checks
  `package.json`.

## Examples

### List every user of a project

```dart
import 'package:tekartik_firebase_auth_node/auth_node.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';

Future<void> listAllUsers(Map<String, Object?> serviceAccountMap) async {
  var app = firebaseNode.initializeApp(
    options: FirebaseAppOptions().withServiceAccountMap(serviceAccountMap),
    name: 'admin',
  );
  var auth = authServiceNode.auth(app);
  String? pageToken;
  do {
    var result = await auth.listUsers(maxResults: 1000, pageToken: pageToken);
    for (var user in result.users) {
      print('${user!.uid} ${user.email} disabled: ${user.disabled}');
    }
    pageToken = result.pageToken;
  } while (pageToken != null && pageToken.isNotEmpty);
  await app.delete();
}
```

### Look up a user and verify an id token (default app)

```dart
import 'package:tekartik_firebase_auth_node/auth_node.dart';
import 'package:tekartik_firebase_node/firebase_node.dart';

/// `[DEFAULT]` app, initialized once at startup with
/// `firebaseNode.initializeApp()` (application default credentials).
Auth get adminAuth => authServiceNode.auth(firebaseNode.app());

Future<UserRecord?> findByEmail(String email) async {
  try {
    return await adminAuth.getUserByEmail(email);
  } catch (e) {
    // firebase-admin rejects with auth/user-not-found
    print('no user for $email: $e');
    return null;
  }
}

/// The uid of a `Bearer <idToken>` authorization header, null when invalid.
Future<String?> uidFromAuthorizationHeader(String? header) async {
  if (header == null || !header.startsWith('Bearer ')) {
    return null;
  }
  try {
    var decoded = await adminAuth.verifyIdToken(header.substring(7));
    return decoded.uid;
  } catch (_) {
    return null;
  }
}
```

### Universal script: local auth on the VM, firebase-admin on node

```dart
import 'package:tekartik_firebase_auth_node/auth_universal.dart';
import 'package:tekartik_firebase_node/firebase_universal.dart';

Future<void> main() async {
  var app = firebaseUniversal.initializeApp();
  var auth = authService.auth(app);
  if (authService.supportsListUsers) {
    var result = await auth.listUsers(maxResults: 10);
    print('${result.users.length} user(s)');
  } else {
    print('listUsers not supported by $authService');
  }
  await app.delete();
}
```

### Node test running the shared auth suite

```dart
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
    test('no env set', () {});
    return;
  }
  if (shouldSkipEnvTestOnGithub()) {
    test('env test skipped on github', () {});
    return;
  }
  group('auth_node', () {
    runAuthTests(
      firebase: firebaseNode,
      authService: authServiceNode,
      options: context.appOptions,
    );
  });
}
```

## Common mistakes

* Calling `getUser` / `getUserByEmail` without a `try`: on node an unknown
  user throws, it does not return `null`.
* Expecting a signed-in user (`currentUser`, `signInWithEmailAndPassword`):
  this is the admin sdk, clients sign in on their side and send an id token.
* Passing a `FirebaseLocal` app to `authServiceNode.auth`.
* Reading `passwordHash` / `passwordSalt` on a record from `getUser`: they are
  only filled by `listUsers`.
