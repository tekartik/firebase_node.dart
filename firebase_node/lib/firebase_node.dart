/// The `tekartik_firebase` API on Node.js over the `firebase-admin` npm
/// module: `firebaseNode` (dart2js, node only).
///
/// `withServiceAccountMap` (initialize an app from a service account) is in
/// `firebase_node_interop.dart`.
library;

export 'package:tekartik_firebase/firebase.dart';

export 'firebase_node_interop.dart' show firebaseNode;
// ignore: invalid_use_of_do_not_submit_member
export 'src/firebase_node_common.dart' show debugFirebaseNode;
