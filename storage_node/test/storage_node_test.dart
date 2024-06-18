@TestOn('node')
library tekartik_firebase_storage_node.storage_node_test;

import 'package:tekartik_firebase_node/firebase_node_interop.dart'
    show firebaseNode;
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:tekartik_firebase_storage_node/src/node/common_import.dart';
import 'package:tekartik_firebase_storage_node/src/node/storage_node.dart'
    show StorageNode, BucketNode;
import 'package:tekartik_firebase_storage_node/storage_node_interop.dart';
import 'package:tekartik_firebase_storage_test/storage_test.dart';

// ignore: depend_on_referenced_packages
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

var _env = platform.environment;

Future<void> main() async {
  var context = await setupOrNull(useEnv: true);

  if (context == null) {
    test('no env set', () {
      // no op
    });
    return;
  }
  if (runningOnGithub && !isGithubActionsUbuntuAndDartStable()) {
    test('Skip on github for other than ubuntu and dart stable', () {
      print('githubActionsPrefix: $githubActionsPrefix');
    });
    return;
  }
  var testRootPath = _env['TEKARTIK_FIREBASE_STORAGE_NODE_TEST_ROOT_PATH'];

  test('env', () {
    print('TEKARTIK_FIREBASE_STORAGE_NODE_TEST_ROOT_PATH: $testRootPath');
  });

  if (testRootPath != null) {
    //var options = storageOptionsFromEnv;
    var app = firebaseNode.initializeApp(options: context.appOptions);
    print('app: ${app.options.projectId}');
    group('node', () {
      setUpAll(() async {});
      runStorageAppTests(app,
          storageService: storageServiceNode,
          storageOptions: TestStorageOptions(rootPath: testRootPath));
      tearDownAll(() {
        return app.delete();
      });

      test('app', () {
        print(app.options.storageBucket);
        print(app.options.projectId);
      });

      test('custom', () async {
        var storageNode = storageServiceNode.storage(app) as StorageNode;
        var bucketNode = storageNode.bucket() as BucketNode;

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
