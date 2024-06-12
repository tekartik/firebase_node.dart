import 'package:tekartik_firebase_storage/storage.dart';
import 'package:tekartik_firebase_storage_node/src/node/storage_node.dart'
    as storage_node;

// Use storageServiceNode instead
@Deprecated('Use storageServiceNode')
StorageService get storageService => storageServiceNode;

/// Get node storage service
StorageService get storageServiceNode => storage_node.storageServiceNode;
