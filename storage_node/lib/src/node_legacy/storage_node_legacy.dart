import 'dart:typed_data';

import 'package:node_interop/util.dart' as node_util;
import 'package:tekartik_firebase_node/impl/firebase_node_legacy.dart';
import 'package:tekartik_firebase_storage/storage.dart';

import 'common_import_legacy.dart';
import 'storage_bindings_legacy.dart' as native;

class StorageServiceNode implements StorageService {
  final _storages = <AppNode, StorageNode>{};

  StorageServiceNode();

  @override
  Storage storage(App app) {
    assert(app is AppNode, 'invalid firebase app type ${app.runtimeType}');
    final appNode = app as AppNode;
    var storage = _storages[appNode];
    if (storage == null) {
      // ignore: invalid_use_of_protected_member
      var storageApp = appNode.nativeInstance!.nativeInstance;
      storage = StorageNode((storageApp as native.StorageApp).storage());
      _storages[appNode] = storage;
    }
    return storage;
  }
}

StorageServiceNode? _storageServiceNode;

StorageServiceNode get storageServiceNode =>
    _storageServiceNode ??= StorageServiceNode();

class StorageNode with StorageMixin implements Storage {
  final native.Storage nativeInstance;

  StorageNode(this.nativeInstance);

  @override
  Bucket bucket([String? name]) {
    native.Bucket? nativeBucket;
    if (name == null) {
      nativeBucket =
          node_util.callMethod(nativeInstance, 'bucket', []) as native.Bucket?;
    } else {
      nativeBucket = nativeInstance.bucket(name);
    }
    return _wrapBucket(nativeBucket)!;
  }
}

class FileNode with FileMixin implements File {
  final native.File nativeInstance;

  FileNode(this.nativeInstance);

  @override
  Future save(/* String | List<int> */ dynamic content) =>
      node_util.promiseToFuture(nativeInstance.save(content));

  @override
  Future<bool> exists() async {
    // Array with first bool as the response
    var fileExistsResponse = (await node_util
        .promiseToFuture<Object?>(nativeInstance.exists())) as List;
    return fileExistsResponse[0] as bool;
  }

  @override
  Future<Uint8List> download() async {
    // Array with first item as the response
    var downloadResponse = (await node_util
        .promiseToFuture<Object?>(nativeInstance.download())) as List;
    return downloadResponse[0] as Uint8List;
  }

  @override
  Future delete() =>
      node_util.promiseToFuture<Object?>(nativeInstance.delete());

  @override
  String toString() =>
      'FileNode($name${metadata != null ? ', metadata: $metadata' : ''})';

  @override
  String get name => nativeInstance.name;

  @override
  Bucket get bucket => BucketNode(nativeInstance.bucket);

  @override
  FileMetadata? get metadata => nativeInstance.metadata == null
      ? null
      : FileMetadataNode(nativeInstance.metadata!);

  @override
  Future<FileMetadata> getMetadata() async {
    var nativeMetadata =
        (await native.fileGetMetaData(nativeInstance)).metadata;
    return FileMetadataNode(nativeMetadata);
  }
}

class BucketNode with BucketMixin implements Bucket {
  final native.Bucket nativeInstance;

  BucketNode(this.nativeInstance);

  @override
  File file(String path) => _wrapFile(nativeInstance.file(path));

  @override
  Future<bool> exists() => node_util
      .promiseToFuture<Object?>(nativeInstance.exists())
      .then((data) => (data as List)[0] as bool);

  @override
  String get name => nativeInstance.name;

  @override
  Future<GetFilesResponse> getFiles([GetFilesOptions? options]) async {
    var nativeResponse = await native.bucketGetFiles(
        nativeInstance, _unwrapGetFilesOptions(options));
    return GetFilesResponseNode(nativeResponse);
  }
}

class GetFilesResponseNode implements GetFilesResponse {
  final native.GetFilesResponse nativeInstance;

  GetFilesResponseNode(this.nativeInstance);

  @override
  List<File> get files => nativeInstance.files.map((e) => FileNode(e)).toList();

  @override
  GetFilesOptions? get nextQuery =>
      _wrapGetFilesOptions(nativeInstance.nextQuery);

  @override
  String toString() => {
        'files': files,
        if (nextQuery != null) 'nextQuery': nextQuery
      }.toString();
}

BucketNode? _wrapBucket(native.Bucket? nativeInstance) =>
    nativeInstance != null ? BucketNode(nativeInstance) : null;

FileNode _wrapFile(native.File nativeInstance) => FileNode(nativeInstance);

native.GetFilesOptions? _unwrapGetFilesOptions(GetFilesOptions? options) {
  if (options == null) {
    return null;
  }
  return native.GetFilesOptions(
    maxResults: options.maxResults,
    prefix: options.prefix,
    autoPaginate: options.autoPaginate,
    pageToken: options.pageToken,
  );
}

GetFilesOptions? _wrapGetFilesOptions(native.GetFilesOptions? options) {
  if (options == null) {
    return null;
  }
  return GetFilesOptions(
      maxResults: options.maxResults,
      prefix: options.prefix,
      autoPaginate: options.autoPaginate,
      pageToken: options.pageToken);
}

class FileMetadataNode implements FileMetadata {
  final native.FileMetadata nativeInstance;

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
