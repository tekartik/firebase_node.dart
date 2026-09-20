---
name: tekartik-pubsub-node-setup
description: >-
  Use when a Dart program compiled for Node.js needs the @google-cloud/pubsub
  npm client through tekartik_pubsub_node: depending on the package, its
  package.json (@google-cloud/pubsub), the pubsub_node.dart import, the
  pubsubJs require binding of src/pubsub_bindings.dart, exploring the module
  with jsObjectKeys, adding dart:js_interop bindings (require from
  tekartik_core_node) on top of it, PUBSUB_EMULATOR_HOST with the firebase
  emulator, and running the node-only tests (dart test -p node,
  nodePackageRunCi).
---

# tekartik_pubsub_node: Google Cloud Pub/Sub client for Node.js (bindings scaffold)

`tekartik_pubsub_node` is the Node.js side of a Pub/Sub client for the tekartik
firebase node packages. Today it is a scaffold: it pins the
`@google-cloud/pubsub` npm module in its `package.json`, loads it with
`require`, and ships the node test setup. The public library
`package:tekartik_pubsub_node/pubsub_node.dart` (which exports
`src/pubsub_interop.dart`) declares nothing yet: treat the package as the
place where Pub/Sub bindings go, not as a ready made client.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_pubsub_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: pubsub_node
  ```
  npm: a `package.json` next to `pubspec.yaml` with
  `"@google-cloud/pubsub": "^5.3.1"`, then `npm install`. Node tooling in
  `dev_dependencies`: `build_runner`, `tekartik_build_node`
  (`https://github.com/tekartik/build_node.dart`, `packages/build_node`),
  `tekartik_app_node_build` (`https://github.com/tekartik/app_node_utils.dart`,
  `app_build`), `process_run`; `dart_test.yaml` with `platforms: [node, vm]`.
* What the package exposes today:
  - `import 'package:tekartik_pubsub_node/pubsub_node.dart';` declares no
    symbol (empty `src/pubsub_interop.dart`).
  - `package:tekartik_pubsub_node/src/pubsub_bindings.dart` declares
    `pubsubJs`, the `JSObject` returned by `require('@google-cloud/pubsub')`,
    marked `@visibleForTesting` (using it outside a test triggers the
    `invalid_use_of_visible_for_testing_member` diagnostic).
* Reaching the module yourself: `require<T extends JSObject>(module)` from
  `package:tekartik_core_node/require.dart` (a dependency of the package) and
  `jsObjectKeys(object)` / `jsObjectGetOwnPropertyNames(object)` from
  `package:tekartik_js_utils_interop/object_keys.dart` (also a dependency) to
  discover what it exports (`PubSub`, `Topic`, `Subscription`, `Message`...).
* Adding bindings: `dart:js_interop` extension types over `JSObject` with
  `external` members named after the npm api, `JSPromise<T>.toDart` for the
  async node calls, `jsify()` / `dartify()` for json values and
  `callAsConstructor` (`dart:js_interop_unsafe`) for `new PubSub(...)`. Put
  them in `lib/src/pubsub_interop.dart` and export the public ones from
  `pubsub_node.dart`. Node only: `require` does not exist in a browser nor on
  the VM, so keep every access behind a `@TestOn('node')` test or a dart2js
  entry point.
* Credentials: the node client reads the Google application default
  credentials (`GOOGLE_APPLICATION_CREDENTIALS`, the Cloud Functions / Cloud
  Run runtime). Against the firebase emulator suite, start it with
  `FirebaseEmulatorOptions(onlyPubsub: true)` (`tekartik_firebase_emulator`)
  and set `PUBSUB_EMULATOR_HOST=localhost:<pubsubPort>` (the
  `EmulatorServiceRunningStatus.pubsubPort`) for the node process.
* Tests and CI: `@TestOn('node')`, `dart test -p node` (needs `npm install`);
  `tool/run_ci.dart` with `nodePackageRunCi('.')` from
  `package:tekartik_app_node_build/package.dart`; `tool/run_node_test.dart`
  running `dart test -p node` through a `process_run` `Shell`.

## Examples

### Explore the module (test/pubsub_node_test.dart)

```dart
@TestOn('node')
library;

import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:tekartik_pubsub_node/src/pubsub_bindings.dart';
import 'package:test/test.dart';

void main() {
  test('module keys', () {
    // [PubSub, Topic, Subscription, Message, Snapshot, ...]
    print(jsObjectKeys(pubsubJs));
    expect(jsObjectKeys(pubsubJs), contains('PubSub'));
  });
}
```

### Minimal binding to publish a json message (your code, npm api names)

```dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_core_node/require.dart';

/// The `@google-cloud/pubsub` module.
extension type PubSubModule._(JSObject _) implements JSObject {
  /// The `PubSub` class, `new PubSub({projectId})`.
  // ignore: non_constant_identifier_names
  external JSFunction get PubSub;
}

/// A `PubSub` client.
extension type PubSub._(JSObject _) implements JSObject {
  external Topic topic(String name);
}

/// A `Topic`.
extension type Topic._(JSObject _) implements JSObject {
  external JSPromise<JSString> publishMessage(JSObject message);
}

final pubsubModule = require<PubSubModule>('@google-cloud/pubsub');

PubSub newPubSub({String? projectId}) => pubsubModule.PubSub
    .callAsConstructor<PubSub>(
      {if (projectId != null) 'projectId': projectId}.jsify(),
    );

/// Returns the message id.
Future<String> publishJson(
  PubSub pubsub,
  String topicName,
  Map<String, Object?> json,
) async {
  var messageId = await pubsub
      .topic(topicName)
      .publishMessage({'json': json}.jsify() as JSObject)
      .toDart;
  return messageId.toDart;
}
```

### tool/run_ci.dart and tool/run_node_test.dart

```dart
import 'package:tekartik_app_node_build/package.dart';

Future<void> main() async {
  await nodePackageRunCi('.');
}
```

```dart
import 'package:process_run/shell.dart';

Future<void> main() async {
  await Shell().run('dart test -p node');
}
```

## Common mistakes

* Expecting a dart Pub/Sub api from `pubsub_node.dart`: nothing is bound yet,
  bindings are yours to add.
* Using `pubsubJs` in library code: it is `@visibleForTesting`, `require` the
  module in your own binding file instead.
* Running the tests on the VM: `require` is undefined there, use
  `dart test -p node`.
