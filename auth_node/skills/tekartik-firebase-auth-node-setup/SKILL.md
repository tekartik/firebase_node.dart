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
  the next call, null on the last page: loop while it is not null);
  `getUser(uid)`, `getUserByEmail(email)` returning a `UserRecord`, null for
  an unknown user (firebase-admin `auth/user-not-found`, any other error
  throws);
  `verifyIdToken(idToken, checkRevoked:)` returning a `DecodedIdToken` (`uid`
  and `signInProvider`, the `firebase.sign_in_provider` claim such as
  `'anonymous'`). The auth is a `FirebaseAuthAdmin` (cast it, from
  `package:tekartik_firebase_auth/auth_admin.dart`): `createUser` (only the
  request fields set are sent) and `deleteUser`. `supportsListUsers` is
  `true`. `createUser` with an email or uid in use and `deleteUser` of an
  unknown uid throw the firebase-admin error as is
  (`auth/email-already-exists`, `auth/uid-already-exists`,
  `auth/user-not-found` in its text), not a `StateError`.
* `UserRecord` fields: `uid`, `email`, `emailVerified`, `displayName`,
  `photoURL`, `phoneNumber`, `disabled`, `customClaims` (a Dart map, the
  decoded json, null when none), `metadata` (`creationTime`,
  `lastSignInTime`, empty when never signed in, `lastRefreshTime`, null when
  never refreshed), `providerData` (`UserInfo` list: `providerId`, `uid`,
  `email`...), `tokensValidAfterTime`, `passwordHash` and `passwordSalt` (only
  on the records of `listUsers`, for a password account). A value
  firebase-admin leaves out is null (no phone, no photo, no display name of
  a provider...). `isAnonymous` is not a firebase-admin field: true for an
  account with no provider, no email and no phone number (as auth_rest).
  `toString()` shows the uid and the email only (`UserRecordNode(uid, email)`).
* Not available server side: `supportsCurrentUser` is `false`;
  `currentUser`, `onCurrentUser` and `reloadCurrentUser` throw
  `UnsupportedError`; `signInWithEmailAndPassword`, `signInAnonymously`,
  `signOut`, `createUserWithEmailAndPassword`, `getUsers`,
  `sendEmailVerification` and `sendPasswordResetEmail` throw the mixin
  `UnsupportedError` / `UnimplementedError`. The js bindings for
  `updateUser` and `setCustomUserClaims` exist in
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
  } while (pageToken != null);
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

/// null when no user has that email.
Future<UserRecord?> findByEmail(String email) =>
    adminAuth.getUserByEmail(email);

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

* Looping on `listUsers` while `pageToken` is not empty: it is null on the
  last page.
* Expecting a signed-in user (`currentUser`, `signInWithEmailAndPassword`):
  this is the admin sdk, clients sign in on their side and send an id token.
* Passing a `FirebaseLocal` app to `authServiceNode.auth`.
* Expecting `passwordHash` / `passwordSalt` on a record from `getUser`: they
  are null, only `listUsers` fills them.
* Printing the `passwordHash` / `passwordSalt` of a `listUsers` record in a CI
  or server log.
