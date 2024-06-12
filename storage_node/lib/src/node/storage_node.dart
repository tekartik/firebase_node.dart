import 'dart:js_interop' as js;
import 'dart:typed_data';

import 'package:tekartik_firebase_node/impl/firebase_node.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase_storage/src/common/storage_service_mixin.dart';

import 'common_import.dart';
import 'storage_node_js_interop.dart' as node;

class StorageServiceNode with StorageServiceMixin implements StorageService {
  StorageServiceNode();

  @override
  Storage storage(App app) {
    return getInstance(app, () {
      assert(app is AppNode, 'invalid firebase app type');
      final appNode = app as AppNode;
      return StorageNode(this,
          node.firebaseAdminStorageModule.getStorage(appNode.nativeInstance));
    });
  }
}

StorageServiceNode? _storageServiceNode;

StorageServiceNode get storageServiceNode =>
    _storageServiceNode ??= StorageServiceNode();

class StorageNode with StorageMixin implements Storage {
  final StorageServiceNode serviceNode;
  final node.Storage nativeInstance;

  StorageNode(this.serviceNode, this.nativeInstance);

  @override
  Bucket bucket([String? name]) {
    node.Bucket? nativeBucket;
    if (name == null) {
      nativeBucket = nativeInstance.bucket();
    } else {
      nativeBucket = nativeInstance.bucket(name);
    }
    return _wrapBucket(this, nativeBucket);
  }
}

class BucketNode with BucketMixin implements Bucket {
  final StorageNode storageNode;
  final node.Bucket nativeInstance;

  BucketNode(this.storageNode, this.nativeInstance);

  @override
  File file(String path) => FileNode(this, nativeInstance.file(path));

  @override
  Future<bool> exists() async => nativeInstance.exists();

  @override
  String get name => nativeInstance.name;

  @override
  Future<GetFilesResponse> getFiles([GetFilesOptions? options]) async {
    var nativeResponse =
        await nativeInstance.getFiles(_unwrapGetFilesOptions(options));
    return GetFilesResponseNode(this, nativeResponse);
  }
}

class FileNode with FileMixin implements File {
  final BucketNode bucketNode;
  final node.File nativeInstance;

  FileNode(this.bucketNode, this.nativeInstance);

  @override
  Future<void> writeAsBytes(Uint8List bytes) async {
    await nativeInstance.save(bytes.toJS).toDart;
  }

  @override
  Future<bool> exists() async => await nativeInstance.exists();

  @override
  Future<Uint8List> download() async {
    // Array with first item as the response
    var downloadResponse =
        (await nativeInstance.download().toDart).toDart as List;
    return (downloadResponse[0] as js.JSUint8Array).toDart;
  }

  @override
  Future delete() => nativeInstance.delete().toDart;

  @override
  String toString() =>
      'FileNode($name${metadata != null ? ', metadata: $metadata' : ''})';

  @override
  String get name => nativeInstance.name;

  @override
  Bucket get bucket => bucketNode;

  @override
  FileMetadata? get metadata => nativeInstance.metadata == null
      ? null
      : FileMetadataNode(nativeInstance.metadata!);

  @override
  Future<FileMetadata> getMetadata() async {
    var nativeMetadata = await nativeInstance.getMetadata();
    return FileMetadataNode(nativeMetadata);
  }
}

class GetFilesResponseNode implements GetFilesResponse {
  final BucketNode bucketNode;
  final node.GetFilesResponse nativeInstance;

  GetFilesResponseNode(this.bucketNode, this.nativeInstance);

  @override
  List<File> get files =>
      nativeInstance.files.map((e) => FileNode(bucketNode, e)).toList();

  @override
  GetFilesOptions? get nextQuery =>
      _wrapGetFilesOptions(nativeInstance.nextQuery);

  @override
  String toString() => {
        'files': files,
        if (nextQuery != null) 'nextQuery': nextQuery
      }.toString();
}

node.GetFilesOptions? _unwrapGetFilesOptions(GetFilesOptions? options) {
  if (options == null) {
    return null;
  }
  return node.GetFilesOptions(
    maxResults: options.maxResults,
    prefix: options.prefix,
    autoPaginate: options.autoPaginate,
    pageToken: options.pageToken,
  );
}

GetFilesOptions? _wrapGetFilesOptions(node.GetFilesOptions? options) {
  if (options == null) {
    return null;
  }
  return GetFilesOptions(
      maxResults: options.maxResults,
      prefix: options.prefix,
      autoPaginate: options.autoPaginate ?? false,
      pageToken: options.pageToken);
}

class FileMetadataNode implements FileMetadata {
  final node.FileMetadata nativeInstance;

  FileMetadataNode(this.nativeInstance);

  @override
  String get md5Hash => base64.encode(nativeInstance.md5Hash.codeUnits);

  @override
  DateTime get dateUpdated => anyToDateTime(nativeInstance.updated)!;

  @override
  int get size => int.tryParse(nativeInstance.size) ?? 0;

  @override
  String toString() => {
        'size': size,
        'dateUpdated': dateUpdated.toUtc().toIso8601String(),
        'md5Hash': md5Hash
      }.toString();
}

BucketNode _wrapBucket(StorageNode storage, node.Bucket nativeInstance) =>
    BucketNode(storage, nativeInstance);
