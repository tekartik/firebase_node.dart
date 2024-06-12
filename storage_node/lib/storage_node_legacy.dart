import 'package:tekartik_firebase_storage/storage.dart';
import 'package:tekartik_firebase_storage_node/src/node_legacy/storage_node_legacy.dart'
    as storage_node;

export 'package:tekartik_firebase_storage_node/src/node_legacy/storage_node_legacy.dart'
    show storageServiceNode, StorageServiceNode, StorageNode, BucketNode;

// Use storageServiceNode instead
@Deprecated('Use storageServiceNode')
StorageService get storageService => storageServiceNode;

/// Get node storage service
StorageService get storageServiceNode => storage_node.storageServiceNode;
