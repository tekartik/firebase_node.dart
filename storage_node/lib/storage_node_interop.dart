import 'package:tekartik_firebase_storage/storage.dart';
import 'package:tekartik_firebase_storage_node/src/node/storage_node.dart'
    as storage_node;

// Use storageServiceNode instead
@Deprecated('Use storageServiceNode')
StorageService get storageService => storageServiceNode;

/// The node storage service (a single instance): `storage(app)` gives the
/// `Storage` of a `firebaseNode` app, cached per app.
///
/// Node.js only: reading it loads `firebase-admin/storage`.
StorageService get storageServiceNode => storage_node.storageServiceNode;
