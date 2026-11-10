# tekartik_firebase_storage_node

The `tekartik_firebase_storage` API (`Storage`, `Bucket`, `File`,
`FileMetadata`, `GetFilesOptions`) on Node.js, over `firebase-admin/storage`
(`@google-cloud/storage`): Dart compiled to JavaScript (dart2js) for Cloud
Functions, Cloud Run or node scripts, with admin rights. Code written against
the API runs unchanged on the other implementations (memory/io
`tekartik_firebase_storage_fs`, Flutter, REST, admin sdk). The app comes from
`tekartik_firebase_node` (same repository).

## Getting started

Not on pub.dev, add it as a git dependency (with `tekartik_firebase_node` for
the app):

```yaml
dependencies:
  tekartik_firebase_storage_node:
    git:
      url: https://github.com/tekartik/firebase_node.dart
      path: storage_node
  tekartik_firebase_node:
    git:
      url: https://github.com/tekartik/firebase_node.dart
      path: firebase_node
```

And the npm modules next to `pubspec.yaml` (`npm install`):

```json
{
  "dependencies": {
    "@google-cloud/storage": "^7.21.0",
    "firebase-admin": "^14.4.0"
  }
}
```

```dart
import 'dart:convert';

import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:tekartik_firebase_storage_node/storage_node.dart';

Future<void> main() async {
  // Application default credentials (Cloud Functions, Cloud Run,
  // GOOGLE_APPLICATION_CREDENTIALS).
  var app = firebaseNode.initializeApp(
    options: FirebaseAppOptions(storageBucket: 'my-project.appspot.com'),
  );
  var storage = storageServiceNode.storage(app);
  var file = storage.bucket().file('notes/hello.txt');
  await file.upload(
    utf8.encode('Hello'),
    options: StorageUploadFileOptions(
      contentType: 'text/plain',
      cacheControl: 'no-cache',
    ),
  );
  print(await file.readAsString());
  var metadata = await file.getMetadata();
  print('${metadata.size} bytes, ${metadata.contentType}');
  await file.delete();
  await app.delete();
}
```

## Platforms

* Node.js only (`dart test -p node`, a dart2js build run by node): reading
  `storageServiceNode` loads `firebase-admin/storage`, so it fails on the VM.
* `package:tekartik_firebase_storage_node/storage_universal.dart` gives
  `storageService`: `storageServiceNode` on node, the in memory
  `storageServiceMemory` (nothing written to disk) on the Dart VM (with
  `firebaseUniversal` of `tekartik_firebase_node`), for a `main` running on
  both.

## What to know

* `storage.bucket()` is the app `storageBucket` option, `storage.bucket(name)`
  a named one (no `gs://` prefix). `bucket.file(path)` is local, nothing is
  sent.
* Listing: `bucket.getFiles(GetFilesOptions(prefix: 'dir/', maxResults: 50,
  autoPaginate: false))` gives at most 50 files and a `nextQuery` (null on the
  last page): pass it back until it is null. An option left null is not sent.
* `file.metadata` is only filled on the files of `getFiles()`; on a
  `bucket.file(path)` it is null, `await file.getMetadata()` instead.
* `md5Hash` is the GCS value (base64), empty for a composite object (GCS
  gives none).
* `storage.ref()`, `getDownloadUrl()` and `bucket.create()` are not
  implemented (they throw).
* Admin rights: the security rules do not apply.

## Testing

`npm install`, then `dart test` (vm and node). `test/storage_node_test.dart`
runs the shared suite (`tekartik_firebase_storage_test`) on a real bucket
when `TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT` (service account file) and
`TEKARTIK_FIREBASE_STORAGE_NODE_TEST_ROOT_PATH` (a throw away prefix: the
suite writes and deletes files under it) are set, for example in
`.local/ds_env.yaml` (see `.local/ds_env.example.yaml`) read by
`dart run tool/run_storage_test_node.dart`.

See `skills/tekartik-firebase-storage-node-setup` for more examples
(`dart run skills@ get`).
