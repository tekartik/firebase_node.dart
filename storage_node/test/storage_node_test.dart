@TestOn('node')
library tekartik_firebase_storage_node.storage_node_test;

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

import 'package:tekartik_firebase_node/firebase_node_interop.dart'
    show firebaseNode;
import 'package:tekartik_firebase_storage_node/src/node/common_import.dart';
import 'package:tekartik_firebase_storage_node/src/node/storage_node.dart'
    show StorageNode, BucketNode;
import 'package:tekartik_firebase_storage_node/src/test/test_environment_client.dart';
// import 'package:tekartik_firebase_storage_node/src/node/node_import.dart'    as interop;
import 'package:tekartik_firebase_storage_node/storage_node_interop.dart';
import 'package:tekartik_firebase_storage_test/storage_test.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart' as js;
import 'package:test/test.dart';

Map errorToMap(js.JSObject e) {
  var map = <String, dynamic>{};
  for (var key in js.jsObjectKeys(e)) {
    //print('$key ${e[key]}');
    print(key);
    print(e.getProperty(key.toJS));
    //map[key] = e[key];
  }
  return map;
}

Future<void> main() async {
  var options = storageOptionsFromEnv;
  var app = await firebaseNode.initializeAppAsync(
      //options: AppOptions(storageBucket: options.storageBucket)
      );
  print('options: $options');
  test('node_env', () async {
    print('options: $options');
  });
  if (options != null) {
    group('node', () {
      setUpAll(() async {});
      runStorageAppTests(app,
          storageService: storageServiceNode,
          storageOptions: storageOptionsFromEnv!);
      tearDownAll(() {
        return app.delete();
      });

      /*
    test('save', () async {
      var bucket = app.storage().bucket('test');
      print('exists ${await bucket.exists()}');
      if (!await bucket.exists()) {
        await bucket.create();
      }
      var file = bucket.file('file');
      try {
        await file.save('content');
      } catch (e) {
        print(objectKeys(e));
        print(e);
        print(errorToMap(e));
      }
    }, skip: true);
    */

      test('app', () {
        print(app.options.apiKey);
        print(app.options.storageBucket);
        print(app.options.projectId);
      });

      test('custom', () async {
        var storageNode = storageServiceNode.storage(app) as StorageNode;
        var bucketNode =
            storageNode.bucket(storageOptionsFromEnv!.bucket) as BucketNode;

        // Add 2 files

        GetFilesOptions? query = GetFilesOptions(
            maxResults: 10, prefix: 'tests', autoPaginate: false);
        String? lastFirstFileName;
        while (true) {
          var response = await bucketNode.getFiles(query);
          // devPrint(response.files);
          var firstFileName = response.files.firstOrNull?.name;
          if (firstFileName != null) {
            expect(firstFileName, isNot(lastFirstFileName));
          }
          lastFirstFileName = firstFileName;
          query = response.nextQuery;
          if (query == null) {
            break;
          }
        }
      }); //, skip: 'temp node test');
      // runApp(app, storageService: storageService);
    });
  }
}
