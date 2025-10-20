library;

import 'dart:js_interop' as js;
import 'dart:js_interop';

// ignore: depend_on_referenced_packages
import 'package:tekartik_core_node/require.dart' as node;
// ignore: implementation_imports
import 'package:tekartik_firebase_node/src/node/firebase_node_js_interop.dart'
    as node;

import 'common_import.dart';

/// Singleton instance of [FirebaseAdmin] module.
final firebaseAdminStorageModule = () {
  return storageModule = node.require<StorageModule>('firebase-admin/storage');
}();

final cloudStorageModule = () {
  return storageModule = node.require<StorageModule>('@google-cloud/storage');
}();

/// First loaded wins
late StorageModule storageModule;
extension type StorageModule._(js.JSObject _) implements js.JSObject {}

extension StorageModuleExt on StorageModule {
  external Storage getStorage(node.App app);
}

extension type Storage._(js.JSObject _) implements js.JSObject {}

extension StorageExt on Storage {
  external Bucket bucket([String? name]);
}

extension type Bucket._(js.JSObject _) implements js.JSObject {}

extension BucketExt on Bucket {
  external String get name;

  @js.JS('exists')
  external js.JSPromise<js.JSArray<js.JSBoolean>> jsExists();

  Future<bool> exists() async {
    return (await jsExists().toDart).toDart.first.toDart;
  }

  external File file(String path);

  /// Get [File] objects for the files currently in the bucket.
  @js.JS('getFiles')
  external js.JSPromise<js.JSArray> jsGetFiles([GetFilesOptions? options]);

  Future<GetFilesResponse> getFiles([GetFilesOptions? options]) async {
    js.JSPromise<js.JSArray> rawGetFiles;
    if (options == null) {
      rawGetFiles = jsGetFiles();
    } else {
      rawGetFiles = jsGetFiles(options);
    }
    var list = (await rawGetFiles.toDart).toDart;
    // devPrint('getFiles: $list ${list.length}');
    // // getFiles: [[[object Object]], null, [object Object]]
    var files = (list.first as js.JSArray<File>).toDart;
    GetFilesOptions? nextQuery;

    nextQuery = list[1] as GetFilesOptions?;

    return GetFilesResponse(files, nextQuery);
  }
}

class GetFilesResponse {
  final List<File> files;
  final GetFilesOptions? nextQuery;

  GetFilesResponse(this.files, this.nextQuery);
}

/// File save options
extension type FileSaveOptions._(JSObject _) implements JSObject {
  external factory FileSaveOptions({String? contentType});
}
extension type File._(js.JSObject _) implements js.JSObject {}

extension FileExt on File {
  external js.JSPromise save(js.JSAny data, [FileSaveOptions options]);

  @js.JS('exists')
  external js.JSPromise<js.JSArray<js.JSBoolean>> jsExists();

  Future<bool> exists() async {
    return (await jsExists().toDart).toDart.first.toDart;
  }

  external js.JSPromise<js.JSArray> download();

  external js.JSPromise delete();

  /// The name of the remote file.
  external String get name;

  /// The bucket instance the is attached to.
  external Bucket get bucket;

  /// The metadata (when read through GetFiles)
  ///
  /// Null for object that are 'folder' like (trailing /)
  external FileMetadata? get metadata;

  /// Get meta data info for the current file
  Future<FileMetadata> getMetadata() async {
    return (await jsGetMetadata().toDart).toDart.first;
  }

  @js.JS('getMetadata')
  external js.JSPromise<js.JSArray<FileMetadata>> jsGetMetadata();

  // Future<GetFileMetadataResponse> fileGetMetaData(File file) async {
  //   var response =
  //       (await node_util.promiseToFuture<Object?>(file.getMetadata())) as List;
  //   // The reponse is an array! first item being the meta data
  //   // devPrint('fileGetMetadataResponse: $response');
  //   var fileMetadata = response[0] as FileMetadata;
  //   return GetFileMetadataResponse(metadata: fileMetadata);
  // }
}

// File meta data in GetFiles
// Simple file:
// {kind: storage#object, id: xxxxx.appspot.com/tests/yyyyyyy/simple_file.txt/1606218107753072,
// selfLink: https://www.googleapis.com/storage/v1/b/xxxxx.appspot.com/o/tests%2Fyyyyyyy%2Fsimple_file.txt,
// mediaLink: https://storage.googleapis.com/download/storage/v1/b/xxxxx.appspot.com/o/tests%2Fyyyyyyy%2Fsimple_file.txt?generation=1606218107753072&alt=media,
// name: tests/yyyyyyy/simple_file.txt,
// bucket: xxxxx.appspot.com, generation: 1606218107753072,
// metageneration: 1, contentType: text/plain, storageClass: STANDARD, size: 40,
// md5Hash: 9iamz8697RUaZ/je/alxAg==, crc32c: RCAaIg==, etag: CPCk+t2Mm+0CEAE=, timeCreated: 2020-11-24T11:41:47.752Z,
// updated: 2020-11-24T11:41:47.752Z, timeStorageClassUpdated: 2020-11-24T11:41:47.752Z}
// Simple folder:
// {kind: storage#object, id: xxxxx.appspot.com/apps//1580594626021569,
// selfLink: https://www.googleapis.com/storage/v1/b/xxxxx.appspot.com/o/apps%2F,
// mediaLink: https://storage.googleapis.com/download/storage/v1/b/xxxxx.appspot.com/o/apps%2F?generation=1580594626021569&alt=media,
// name: apps/, bucket: xxxxx.appspot.com, generation: 1580594626021569, metageneration: 1,
// contentType: application/x-www-form-urlencoded;charset=UTF-8, storageClass:
// STANDARD, size: 0, md5Hash: 1B2M2Y8AsgTpgAmY7PhCfg==, contentDisposition: inline; filename*=utf-8''apps,
// crc32c: AAAAAA==, etag: CMGR3+mtsecCEAE=, timeCreated: 2020-02-01T22:03:46.021Z, updated: 2020-02-01T22:03:46.021Z,
// timeStorageClassUpdated: 2020-02-01T22:03:46.021Z, metadata: {firebaseStorageDownloadTokens: 3712857b-088d-4ed5-8604-7b084ac0e76e}}
extension type FileMetadata._(js.JSObject _) implements js.JSObject {}

extension FileMetadataExt on FileMetadata {
  external String get md5Hash;

  external String get size;

  external String get updated;

  external String? get contentType;
}

extension type GetFilesOptions._(js.JSObject _) implements js.JSObject {
  external factory GetFilesOptions({
    int? maxResults,
    String? prefix,
    bool? autoPaginate,
    String? pageToken,
  });
}

extension GetFilesOptionsExt on GetFilesOptions {
  external int? get maxResults;

  external String? get prefix;

  external String? get pageToken;

  external bool? get autoPaginate;
}
