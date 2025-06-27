import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:tekartik_firebase_storage_node/src/node/common_import.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_storage_test/storage_test.dart';

var _env = platform.environment;
TestStorageOptions? _storageOptionsFromEnv;

TestStorageOptions? getStorageOptionsFromEnv(Map<String, String> env) {
  var storageBucket = env['firebaseStorageTestBucket'];
  var rootPath = env['firebaseStorageTestRootPath'];
  if (storageBucket != null && rootPath != null) {
    return TestStorageOptions(bucket: storageBucket, rootPath: rootPath);
  } else {
    print(
      'missing firebaseStorageTestBucket or firebaseStorageTestRootPath env variable',
    );
    return null;
  }
}

/// Get storage option from env on node, dummy on io
TestStorageOptions? get storageOptionsFromEnv => _storageOptionsFromEnv ??= () {
  if (isRunningAsJavascript) {
    return getStorageOptionsFromEnv(_env);
  } else {
    // io sim
    return TestStorageOptions(bucket: 'local');
  }
}();
