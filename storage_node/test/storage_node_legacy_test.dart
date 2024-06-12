@TestOn('node')
library tekartik_firebase_storage_node.storage_node_test;

import 'package:node_interop/util.dart' as node_util;
import 'package:tekartik_firebase_node/firebase_node_legacy.dart'
    show firebaseNode;
import 'package:tekartik_firebase_storage/storage.dart';
import 'package:tekartik_firebase_storage_node/src/node_legacy/common_import_legacy.dart';
import 'package:tekartik_firebase_storage_node/src/node_legacy/node_import_legacy.dart'
    as interop;
import 'package:tekartik_firebase_storage_node/src/test/test_environment_client.dart';
import 'package:tekartik_firebase_storage_node/storage_node.dart';
import 'package:tekartik_firebase_storage_test/storage_test.dart';
import 'package:test/test.dart';

Map errorToMap(Object e) {
  var map = <String, dynamic>{};
  for (var key in interop.objectKeys(e)) {
    //print('$key ${e[key]}');
    print(key);
    print(node_util.getProperty(e, key));
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
      runApp(app,
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
          var firstFileName = response.files.firstOrNull?.name;
          if (firstFileName != null) {
            expect(firstFileName, isNot(lastFirstFileName));
          }
          lastFirstFileName = firstFileName;

          // devPrint(response.files);
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
