/// Admin auth on Node.js (firebase-admin): `authServiceNode`, with the
/// `tekartik_firebase_auth` API (`FirebaseAuth`, `UserRecord`...).
///
/// `authServiceNode.auth(app)` on a `firebaseNode` app
/// (`tekartik_firebase_node`); cast it to `FirebaseAuthAdmin` for
/// `createUser` and `deleteUser`. Node.js only.
library;

export 'package:tekartik_firebase_auth/auth.dart';
export 'auth_node_interop.dart' show authServiceNode, authService;
