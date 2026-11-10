# tekartik_firebase_auth_node

The admin side of the `tekartik_firebase_auth` API (users, id tokens) on
Node.js, over the `firebase-admin` npm module: Dart compiled to JavaScript
(dart2js) for Cloud Functions, Cloud Run or node scripts. The app comes from
`tekartik_firebase_node` (same repository).

## Getting started

Not on pub.dev, add it as a git dependency (with `tekartik_firebase_node` for
the app):

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

And the npm module next to `pubspec.yaml` (`npm install`):

```json
{
  "dependencies": {
    "firebase-admin": "^14.4.0"
  }
}
```

```dart
import 'package:tekartik_firebase_auth/auth_admin.dart';
import 'package:tekartik_firebase_auth_node/auth_node.dart';
import 'package:tekartik_firebase_node/firebase_node_interop.dart';

Future<void> listUsers(Map<String, Object?> serviceAccountMap) async {
  var app = firebaseNode.initializeApp(
    options: FirebaseAppOptions().withServiceAccountMap(serviceAccountMap),
    name: 'admin',
  );
  var auth = authServiceNode.auth(app) as FirebaseAuthAdmin;
  String? pageToken;
  do {
    var result = await auth.listUsers(maxResults: 1000, pageToken: pageToken);
    for (var user in result.users.nonNulls) {
      print('${user.uid} ${user.email} anonymous: ${user.isAnonymous}');
    }
    pageToken = result.pageToken; // null on the last page
  } while (pageToken != null);
  // null when no such user.
  var user = await auth.getUserByEmail('someone@example.com');
  print('found: ${user?.uid}');
  await app.delete();
}
```

## Platforms

* Node.js only (`dart test -p node`, a dart2js build run by node): reading
  `authServiceNode` loads `firebase-admin/auth`.
* `package:tekartik_firebase_auth_node/auth_universal.dart` gives
  `authService`: `authServiceNode` on node, the in memory
  `authServiceLocal` on the Dart VM (with `firebaseUniversal` of
  `tekartik_firebase_node`), for a `main` running on both.

## What it does

* `listUsers` (`pageToken` null on the last page), `getUser`,
  `getUserByEmail` (null for an unknown user), `verifyIdToken` (an invalid or
  revoked token throws), and, through `FirebaseAuthAdmin`, `createUser` and
  `deleteUser`.
* A `UserRecord` has the firebase-admin values; the ones firebase-admin
  leaves out are null (no phone number, no photo...). `passwordHash` and
  `passwordSalt` are only set on the records of `listUsers`, for a password
  account. `customClaims` is a Dart map. `isAnonymous` (not a firebase-admin
  field) is true for an account without provider, email nor phone number.
* No signed in user on a server: `currentUser`, `onCurrentUser`, the sign in
  methods throw.

## Common pitfalls

* `createUser` with an email or uid in use, `deleteUser` of an unknown uid:
  the firebase-admin error comes through as is (`auth/email-already-exists`,
  `auth/user-not-found` in its text).
* A `listUsers` record holds the password hash and salt: its `toString()`
  shows only the uid and the email, do not log its other fields.

## Testing

`npm install`, then `dart test -p node` (`-p vm` for the VM tests). The tests
reaching a real project read a service account from
`TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT`; without it they are a single
no-op test. The agent skill
[tekartik-firebase-auth-node-setup](skills/tekartik-firebase-auth-node-setup/SKILL.md)
has more examples.
