---
name: tekartik-firebase-storage-node-setup
description: >-
  Use when reading or writing Cloud Storage objects from Node.js (dart2js,
  firebase-admin and @google-cloud/storage) with
  tekartik_firebase_storage_node: storageServiceNode,
  storageServiceNode.storage(app) on a firebaseNode app, the storage_node.dart
  / storage_node_interop.dart / storage_universal.dart imports (storageService:
  node in JS, the in-memory storage_fs service on the VM), bucket.file /
  getFiles paging, file.writeAsString / readAsBytes / upload / getMetadata on
  node, package.json @google-cloud/storage and firebase-admin, and running the
  shared runStorageAppTests suite on node with
  TEKARTIK_FIREBASE_STORAGE_NODE_TEST_ROOT_PATH.
---

# tekartik_firebase_storage_node: Cloud Storage on Node.js

`tekartik_firebase_storage_node` implements the `tekartik_firebase_storage`
abstractions (`FirebaseStorageService`, `Storage`, `Bucket`, `File`,
`FileMetadata`, `GetFilesOptions`) over `firebase-admin/storage` and
`@google-cloud/storage` through `dart:js_interop`. The dart API is the one
shared with `tekartik_firebase_storage_fs` (memory / io) and the flutter and
rest implementations, so storage code stays platform neutral: only the service
getter differs.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_firebase_storage_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: storage_node
      version: '>=0.4.0'
    tekartik_firebase_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_node
  ```
  It brings `tekartik_firebase_storage` (the API) and
  `tekartik_firebase_storage_fs` (the VM fallback of the universal library).
  npm side: a `package.json` next to `pubspec.yaml` with
  `"firebase-admin": "^14.4.0"` and `"@google-cloud/storage": "^7.21.0"`, then
  `npm install`. `dart_test.yaml`: `platforms: [node, vm]`.
* Imports:
  - `package:tekartik_firebase_storage_node/storage_node.dart` re-exports
    `package:tekartik_firebase_storage/storage.dart` (and through it
    `tekartik_firebase`) and adds `storageServiceNode`.
  - `package:tekartik_firebase_storage_node/storage_node_interop.dart`:
    `storageServiceNode` only (plus the deprecated `storageService` alias of
    it — do not use that name from this library).
  - `package:tekartik_firebase_storage_node/storage_universal.dart` re-exports
    the API and adds `storageService`: `storageServiceNode` when compiled to
    JS, `storageServiceMemory` (`tekartik_firebase_storage_fs`, **in memory**,
    nothing is written to disk) on the VM, an `UnsupportedError` elsewhere.
    Pair it with `firebaseUniversal` from
    `package:tekartik_firebase_node/firebase_universal.dart`.
  - `storage_node_legacy.dart` and `storage_universal_legacy.dart` are
    deprecated aliases; never import `src/node/...` outside this package.
* `storageServiceNode` is a lazily built singleton; keep one per process.
  `storageServiceNode.storage(app)` returns the `Storage` of a `firebaseNode`
  app, cached per app and registered on it (`app.storage()` gives it back). It
  asserts the app is an `AppNode`, so a `FirebaseLocal` / VM app cannot be
  passed in. Initialize the app first (service account or application default
  credentials, see the `tekartik-firebase-node-setup` skill).
* `storage.bucket()` uses the app `storageBucket` option (set it at
  `initializeApp` time), `storage.bucket(name)` a named bucket, never with a
  `gs://` prefix. `bucket.exists()` and `bucket.getFiles()` hit the backend;
  `bucket.file(path)` is purely local (bucket relative path, no leading `/`).
* Supported on node: `file.upload(bytes, options:
  StorageUploadFileOptions(contentType: ...))` (mapped to the native
  `save(..., {contentType})`), `writeAsBytes` / `writeAsString` (UTF-8),
  `readAsBytes` / `readAsString` (whole object in memory), `exists()`,
  `delete()`, `getMetadata()`, `name`, `bucket`, and `bucket.getFiles()`.
  Not implemented here (they throw `UnimplementedError` from the base mixins):
  `storage.ref(...)` / `getDownloadUrl()` and `bucket.create()` — create
  buckets in the console or with the gcloud tooling.
* `getMetadata()` returns a `FileMetadata` whose `size` is parsed from the
  native string (`0` when unparsable), `dateUpdated` from the native `updated`
  field and `md5Hash` base64 re-encoded. The `file.metadata` *getter* is only
  the native cache: it is filled on files returned by `getFiles()` and null on
  a `bucket.file(path)` reference, so always `await getMetadata()` there.
* Listing pages: `bucket.getFiles(GetFilesOptions(prefix: 'dir/', maxResults:
  50, autoPaginate: false))` returns a `GetFilesResponse` with `files` and a
  `nextQuery` (the native next query wrapped back, `pageToken` included). Loop
  while `nextQuery != null`, passing it straight back; do not stop on an empty
  page.
* Platform split: type shared code on `Storage` / `Bucket` / `File` and pick
  `storageServiceNode` in the node entry point (dart2js `main`,
  `@TestOn('node')` test), or use `storage_universal.dart` for a `main` that
  must also run on the VM. Merely accessing `storageServiceNode` on the VM
  fails: the `firebase-admin` module is `require`d at first use.
* Tests: `dart test -p node` (node on the path, `npm install` done). The real
  project tests read the service account from
  `TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT` through `setupOrNull(useEnv:
  true)` (`package:tekartik_firebase_node/test/setup.dart`) and a dedicated
  prefix from `TEKARTIK_FIREBASE_STORAGE_NODE_TEST_ROOT_PATH` (read with
  `platform.environment` from
  `package:tekartik_platform_node/context_universal.dart`); both live in
  `.local/ds_env.yaml` locally, and `shouldSkipEnvTestOnGithub()` keeps them
  out of the regular github workflow. Never point `rootPath` at real data: the
  suite creates and deletes objects under it.
* Shared suite: `runStorageAppTests(app, storageService: storageServiceNode,
  storageOptions: TestStorageOptions(rootPath: ...))` from
  `package:tekartik_firebase_storage_test/storage_test.dart` (or
  `runStorageTests(firebase: ..., storageService: ..., options: ...,
  storageOptions: ...)` which initializes and deletes the app itself).
  `TestStorageOptions(bucket: ..., rootPath: ..., skipDefaultBucketExists:
  true)` targets an explicit bucket.
* `test/package_json_test.dart` (VM) runs `firebaseNodePackageJsonTests(
  requiredDependencies: [firebaseAdminNpmPackageName])` from
  `tekartik_firebase_node_test`; add `'@google-cloud/storage'` to
  `requiredDependencies` to also require the storage npm module.
* Tooling: `tool/run_ci.dart` calls `nodePackageRunCi('.')`
  (`package:tekartik_app_node_build/package.dart`), and a single node test file
  is run through `nodePackageRunTest('.', testFiles: ['test/x_test.dart'])`
  (`package:tekartik_build_node/build_node.dart`).

## Examples

### Node script: upload, read back, delete

```dart
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_storage_node/storage_node.dart';

/// Compiled with dart2js and run with node.
Future<void> main() async {
  var app = firebaseNode.initializeApp(
    options: FirebaseAppOptions(
      projectId: 'my-project',
      storageBucket: 'my-project.firebasestorage.app',
    ),
  );
  var storage = storageServiceNode.storage(app);
  var file = storage.bucket().file('tests/hello.txt');

  await file.writeAsString('hello');
  print(await file.readAsString());

  var metadata = await file.getMetadata();
  print('${metadata.size} bytes, ${metadata.contentType}, '
      '${metadata.dateUpdated}');

  await file.delete();
  await app.delete();
}
```

### Upload bytes with a content type (platform neutral, takes a Bucket)

```dart
import 'dart:typed_data';

import 'package:tekartik_firebase_storage_node/storage_node.dart';
import 'package:tekartik_firebase_storage/utils/content_type.dart';

Future<void> uploadImage(Bucket bucket, String path, Uint8List bytes) async {
  await bucket.file(path).upload(
    bytes,
    options: StorageUploadFileOptions(
      contentType:
          firebaseStorageContentTypeFromFilename(path) ??
          firebaseStorageDefaultContentType,
    ),
  );
}
```

### Listing a prefix page by page

```dart
import 'package:tekartik_firebase_storage_node/storage_node.dart';

Future<List<String>> listPaths(Bucket bucket, String prefix) async {
  var paths = <String>[];
  GetFilesOptions? query = GetFilesOptions(
    prefix: prefix,
    maxResults: 50,
    autoPaginate: false,
  );
  while (query != null) {
    var response = await bucket.getFiles(query);
    for (var file in response.files) {
      // metadata is the getFiles cache here, it can be null.
      paths.add('${file.name} (${file.metadata?.size ?? -1})');
    }
    query = response.nextQuery;
  }
  return paths;
}
```

### Same main on node (firebase-admin) and on the VM (memory)

```dart
import 'package:tekartik_firebase_node/firebase_universal.dart';
import 'package:tekartik_firebase_storage_node/storage_universal.dart';

Future<void> main() async {
  var app = firebaseUniversal.initializeApp(
    options: FirebaseAppOptions(
      projectId: 'my-project',
      storageBucket: 'my-project.firebasestorage.app',
    ),
  );
  // storageServiceNode in JS, in-memory storage_fs on the VM.
  var storage = storageService.storage(app);
  await storage.bucket().file('demo/info.txt').writeAsString('hello');
  await app.delete();
}
```

### Node test running the shared storage suite

```dart
@TestOn('node')
library;

import 'package:tekartik_firebase_node/firebase_node_interop.dart'
    show firebaseNode;
import 'package:tekartik_firebase_node/test/setup.dart';
import 'package:tekartik_firebase_storage_node/storage_node_interop.dart';
import 'package:tekartik_firebase_storage_test/storage_test.dart';
import 'package:tekartik_platform_node/context_universal.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var context = await setupOrNull(useEnv: true);
  if (context == null || shouldSkipEnvTestOnGithub()) {
    test('no env set', () {});
    return;
  }
  var rootPath =
      platform.environment['TEKARTIK_FIREBASE_STORAGE_NODE_TEST_ROOT_PATH'];
  if (rootPath == null) {
    test('no root path set', () {});
    return;
  }
  var app = firebaseNode.initializeApp(options: context.appOptions);
  group('node', () {
    runStorageAppTests(
      app,
      storageService: storageServiceNode,
      storageOptions: TestStorageOptions(rootPath: rootPath),
    );
    tearDownAll(() => app.delete());
  });
}
```

### package.json check (VM)

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  firebaseNodePackageJsonTests(
    requiredDependencies: [firebaseAdminNpmPackageName, '@google-cloud/storage'],
  );
}
```

## Common mistakes

* Touching `storageServiceNode` on the VM (it `require`s `firebase-admin`):
  use `storage_universal.dart` or keep it in node-only code.
* Passing a `FirebaseLocal` / memory app to `storageServiceNode.storage(app)`.
* Expecting `storage.ref(...)`, `getDownloadUrl()` or `bucket.create()` to
  work on node: they throw `UnimplementedError`.
* Reading `file.metadata` on a `bucket.file(path)` reference (it is null)
  instead of awaiting `getMetadata()`.
* Stopping a `getFiles` loop on an empty `files` page instead of a null
  `nextQuery`.
* Assuming the universal VM fallback persists anything: it is in memory only.
* Forgetting `@google-cloud/storage` in `package.json`, or `npm install`,
  before `dart test -p node`.
* Reading a large object with `readAsBytes()` / `readAsString()`: it is all
  loaded in memory.
