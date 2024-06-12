@TestOn('node')
library;

import 'package:tekartik_firebase_storage_node/src/node/storage_node_js_interop.dart'
    as node;
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:test/test.dart';

void main() {
  // ignore: unnecessary_statements
  node.firebaseAdminStorageModule;
  group('no_app', () {
    test('firebaseAdminStorageModule', () {
      print(jsObjectKeys(node.firebaseAdminStorageModule));
      // [ApiError, IdempotencyStrategy, Storage, Bucket, Channel, File,
      // HmacKey, Iam, Notification, CRC32C, CRC32C_DEFAULT_VALIDATOR_GENERATOR,
      // CRC32C_EXCEPTION_MESSAGES, CRC32C_EXTENSIONS, CRC32C_EXTENSION_TABLE,
      // HashStreamValidator, MultiPartUploadError, TransferManager]
      print(jsObjectKeys(node.cloudStorageModule));
    });
    test('GetAppOptions', () {
      var options = node.GetFilesOptions(maxResults: 10);
      expect(options.maxResults, 10);
    });
  });
}
