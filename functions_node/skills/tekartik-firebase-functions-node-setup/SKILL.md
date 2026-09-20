---
name: tekartik-firebase-functions-node-setup
description: >-
  Use when writing, building, serving or deploying Cloud Functions for
  Firebase in Dart compiled to Node.js with tekartik_firebase_functions_node:
  firebaseFunctionsNode, firebaseFunctionsUniversal / firebaseFunctions (node
  in JS, a local http server on the VM), https.onRequest / onRequestV2 /
  onCall, ExpressHttpRequest and response.send, CallRequest and HttpsError,
  scheduler.onSchedule with ScheduleOptions, firestore.document().onWrite,
  GlobalOptions and regions, registering with functions['name'] =, the
  bin/main.dart + build_web_compilers (dart2js) layout, deploy/functions
  package.json, gcfNodePackageBuild / GcfNodeAppBuilder, the functions
  emulator and package.json firebase-functions.
---

# tekartik_firebase_functions_node: Cloud Functions for Firebase in Dart, on Node.js

`tekartik_firebase_functions_node` implements the `tekartik_firebase_functions`
api over the `firebase-functions` (v2) npm module through `dart:js_interop`:
a `bin/main.dart` registers the functions, dart2js compiles it to
`deploy/functions/index.js`, and the `firebase` cli serves or deploys it. The
same `main` runs on the VM through `firebaseFunctionsUniversal` as a plain
http server (`tekartik_firebase_functions_http` + `tekartik_http_io`), which
is how functions are developed and unit tested without node.

## Guidelines

* Dependency (git, not on pub.dev) and build tooling:
  ```yaml
  dependencies:
    tekartik_firebase_functions_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: functions_node
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.7.0'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
    tekartik_app_node_build:
      git:
        url: https://github.com/tekartik/app_node_utils.dart
        path: app_build
  ```
  It brings `tekartik_firebase_functions` (the api),
  `tekartik_firebase_firestore_node`, `tekartik_firebase_auth_node` and
  `tekartik_firebase_node`. `build.yaml` compiles `bin/**` with dart2js:
  ```yaml
  targets:
    $default:
      sources:
        - $package$
        - lib/**
        - bin/**
        - test/**
      builders:
        build_web_compilers|entrypoint:
          generate_for:
            - bin/**
          options:
            compiler: dart2js
  ```
* Firebase folder `deploy/`: `firebase.json` with `"functions": [{"source":
  "functions", "codebase": "default", "ignore": ["node_modules", ".git",
  "*.local"]}]` and the `emulators` ports (functions 5001);
  `.firebaserc` written by `firebase use --add <project-id>` run in `deploy/`;
  `deploy/functions/package.json` with `"main": "index.js"`,
  `"engines": {"node": "24"}`, `"firebase-admin": "^14.4.0"` and
  `"firebase-functions": "^7.3.2"`, then `npm install` there. The dart package
  itself needs the same two npm modules in its own `package.json` for
  `dart test -p node`.
* Imports:
  - `package:tekartik_firebase_functions_node/firebase_functions_universal.dart`:
    the api (`package:tekartik_firebase_functions/firebase_functions.dart`,
    which re-exports `tekartik_firebase` and `tekartik_http/http_server.dart`),
    `tekartik_firebase_local`, and `firebaseFunctionsUniversal` /
    `firebaseFunctionsServiceUniversal` (shortcuts `firebaseFunctions`,
    `firebaseFunctionsService`), the `FirebaseFunctionsUniversal` /
    `FirebaseFunctionsServiceUniversal` types and the `serveUniversal()`
    extension. Node implementation in JS, http server on the VM, throws
    elsewhere. `firebaseFunctionsUniversalV1` / `V2` are deprecated aliases.
  - `package:tekartik_firebase_functions_node/firebase_functions_node.dart`:
    the api plus `firebaseFunctionsNode` (node only; its `serve()` throws,
    only the universal instance has the no-op `serve`).
  - the app: `firebaseUniversal` (`package:tekartik_firebase_node/firebase_universal.dart`)
    or `firebaseNode`.
* Entry point `bin/main.dart`: `firebaseUniversal.initializeApp()` when the
  functions use firebase services, then `functions['name'] =
  functions.https.onRequest(handler)` (same as `registerFunction(name, fn)`)
  for each function, finally `await functions.serve()`. On node `serve()` is a
  no-op (the cli loads `index.js` and reads the exported functions; the
  returned `FfServer.uri` throws); on the VM it binds an `HttpServer`
  (`serve(port:)`, `0` for a free port, `server.uri`, `server.close()`).
* Function names on node (v2): lowercase letters, digits and hyphens, at most
  62 characters (`hello-world` or `helloworldv2`, not `helloWorld`).
* HTTPS: `https.onRequest(handler, httpsOptions: HttpsOptions(region:, cors:,
  memory:, timeoutSeconds:))` (`onRequestV2(options, handler)` is the same
  with required options). The handler receives an `ExpressHttpRequest`:
  `method`, `uri` (path and query of the node request url), `headers`
  (`value(name)`), `body` (bytes; `bodyAsMap`, `bodyAsText`, `bodyAsString`
  extensions). Set `response.statusCode` and `response.headers`, then finish
  with `await request.response.send(body)` where body is a `String`, a
  `Uint8List` / `List<int>`, or a `Map` / `List` (json encoded);
  `response.redirect(uri)` also ends it. `write`, `writeln` and `add` throw
  `UnimplementedError` on node: build the body, `send` it once.
* Callable: `https.onCall(handler, callableOptions:
  HttpsCallableOptions(region:, cors:, enforceAppCheck:))`. The handler
  receives a `CallRequest`: `data` (decoded json), `dataAsMap`,
  `context.auth?.uid` and `context.auth?.token` (a `DecodedIdToken`); it
  returns a json-encodable value. Throw `HttpsError(HttpsErrorCode.notFound,
  'message', details)` to fail with a code the client decodes.
* Scheduler: `scheduler.onSchedule(ScheduleOptions(schedule: 'every 5
  minutes', timeZone: 'Europe/Paris', region:, memory:, timeoutSeconds:),
  (event) async { ... })`; `event.jobName`, `event.scheduleTime`.
* Firestore triggers: `firestore.document('col/{id}').onWrite((change,
  context) async { ... })` maps to `onDocumentWritten`; `change.after` is the
  `DocumentSnapshot` (`change.before` currently returns the same after
  snapshot, `context.params` is empty, `context.timestamp` is the handler
  time). `onCreate`, `onUpdate`, `onDelete` throw `UnimplementedError`. The
  trigger reads through `firestoreServiceNode.firestore(firebaseNode.app())`,
  so the default app must be initialized first.
* `functions.globalOptions = GlobalOptions(region: regionBelgium, memory:
  '256MiB', timeoutSeconds: 60, concurrency: 80)` sets the defaults of the
  functions registered afterwards (`regions` and `maxInstances` are not
  forwarded on node). `regionBelgium` (`europe-west1`), `regionFrankfurt` and
  `regionUsCentral1` (the emulator default) are constants of the api.
  `functions.params.projectId` reads the deployed project id. `pubsub`,
  `region()` and `runWith()` throw on node.
* Firebase services inside a function: `firebaseNode.initializeApp()` once
  at startup (default credentials on Cloud Functions), then
  `firestoreServiceNode.firestore(firebaseNode.app())` /
  `authServiceNode.auth(firebaseNode.app())`. `functions.app` on node is that
  default app (a `StateError` says to call `initializeApp` first).
* Build, serve, deploy (`package:tekartik_app_node_build/gcf_build.dart`):
  `gcfNodePackageBuild('.')` compiles `bin/main.dart` to
  `deploy/functions/index.js`; `gcfNodePackageServeFunctions('.')` serves it
  with the functions emulator; `gcfNodePackageDeployFunctions('.', projectId:)`
  deploys; or `GcfNodeAppBuilder(options: GcfNodeAppOptions(projectId:,
  deployDir: 'deploy', functions: [...]))` with `build()`, `buildAndServe()`,
  `serveFunctions()`, `deployFunctions(functions:)`. Local url:
  `http://localhost:5001/<projectId>/<region>/<function>`.
* Emulator in tests (`tekartik_firebase_emulator`, `@TestOn('vm')`):
  `FirebaseEmulatorService(path: 'deploy')`, `isSupported()` to skip,
  `gcfNodePackageBuild('.')` then `start(options:
  FirebaseEmulatorOptions(onlyFunctions: true))`, `emulator.projectId` for the
  url, `stop()` in `tearDownAll`, a 5 minutes group timeout.
* VM tests without node: `firebaseFunctionsUniversal.serve(port: 0)` and any
  http client on `server.uri`. Shared helpers of
  `package:tekartik_firebase_functions_test/firebase_functions_test_runner.dart`:
  `initFunctionsBasic(functions, prefix:)` registers a `<prefix>basic`
  callable, `basicTestGroup(() => testContext)` calls it through a
  `FirebaseFunctionsTestClientContext`.
* `firebaseNodePackageJsonTests(requiredDependencies:
  [firebaseAdminNpmPackageName, firebaseFunctionsNpmPackageName])`, once for
  the package and once with `path: 'deploy/functions'`
  (`tekartik_firebase_node_test`), keeps both `package.json` in range.

## Examples

### bin/main.dart: request, callable and scheduled functions

```dart
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_firebase_node/firebase_universal.dart';

Future<void> main() async {
  firebaseUniversal.initializeApp();
  var functions = firebaseFunctionsUniversal;
  functions.globalOptions = GlobalOptions(region: regionBelgium);

  functions['hello'] = functions.https.onRequest(hello);
  functions['hellocors'] = functions.https.onRequest(
    hello,
    httpsOptions: HttpsOptions(cors: true),
  );
  functions['echo'] = functions.https.onCall(echo);
  functions['cleanup'] = functions.scheduler.onSchedule(
    ScheduleOptions(schedule: 'every 24 hours', timeZone: 'Europe/Paris'),
    (event) async {
      print('cleanup ${event.jobName} at ${event.scheduleTime}');
    },
  );

  // No-op on node (firebase serves index.js), an http server on the VM.
  await functions.serve();
}

Future<void> hello(ExpressHttpRequest request) async {
  if (request.method != 'GET') {
    request.response.statusCode = 405;
    await request.response.send('GET only');
    return;
  }
  await request.response.send('Hello ${request.uri.path}');
}

Future<Object?> echo(CallRequest request) async {
  var uid = request.context.auth?.uid;
  if (uid == null) {
    throw HttpsError(HttpsErrorCode.unauthenticated, 'Sign in first');
  }
  return {'uid': uid, 'data': request.data};
}
```

### Firestore trigger with admin access (node only entry point)

```dart
import 'package:tekartik_firebase_firestore_node/firestore_node.dart';
import 'package:tekartik_firebase_functions_node/firebase_functions_node.dart';
import 'package:tekartik_firebase_node/firebase_node.dart';

void main() {
  // Default credentials on Cloud Functions; needed by the firestore trigger.
  firebaseNode.initializeApp();
  var functions = firebaseFunctionsNode;
  var firestore = firestoreServiceNode.firestore(firebaseNode.app());

  functions['onnotewritten'] = functions.firestore
      .document('notes/{noteId}')
      .onWrite((change, context) async {
        var snapshot = change.after;
        if (!snapshot.exists) {
          return; // deleted
        }
        await firestore.doc('stats/notes').set({
          'lastWritten': snapshot.ref.path,
          'at': FieldValue.serverTimestamp,
        }, SetOptions(merge: true));
      });
  // no serve() here: the firebase cli loads the exported functions
}
```

### tool/build_and_serve.dart and tool/deploy.dart

```dart
import 'package:tekartik_app_node_build/gcf_build.dart';

var builder = GcfNodeAppBuilder(
  options: GcfNodeAppOptions(
    projectId: 'my-project-id',
    deployDir: 'deploy',
    functions: ['hello', 'echo', 'cleanup'],
  ),
);

/// Compiles bin/main.dart to deploy/functions/index.js and starts the
/// functions emulator (http://localhost:5001/my-project-id/europe-west1/hello).
Future<void> main() async {
  await builder.buildAndServe();
}
```

```dart
import 'package:tekartik_app_node_build/gcf_build.dart';

Future<void> main() async {
  await gcfNodePackageBuild('.');
  await gcfNodePackageDeployFunctions('.', projectId: 'my-project-id');
}
```

### VM test through the universal http server

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:test/test.dart';

void main() {
  test('hello over http', () async {
    var functions = firebaseFunctionsUniversal;
    functions['hello'] = functions.https.onRequest((request) async {
      await request.response.send('Hello');
    });
    var server = await functions.serve(port: 0);
    var client = httpClientFactoryIo.newClient();
    try {
      var text = await httpClientRead(
        client,
        httpMethodGet,
        server.uri.replace(path: '/hello'),
      );
      expect(text, 'Hello');
    } finally {
      client.close();
      await server.close();
    }
  });
}
```

### package.json checks (VM)

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  var required = [firebaseAdminNpmPackageName, firebaseFunctionsNpmPackageName];
  // The package itself (dart test -p node)...
  firebaseNodePackageJsonTests(requiredDependencies: required);
  // ...and the generated functions package
  firebaseNodePackageJsonTests(
    path: 'deploy/functions',
    requiredDependencies: required,
  );
}
```

## Common mistakes

* Calling `response.write` / `writeln` / `add` on node: only `send` and
  `redirect` are implemented.
* Camel case or long function names on node v2 deployments.
* Calling `firebaseFunctionsNode.serve()` (throws); the universal entry point
  is the one whose `serve()` is a no-op on node.
* Using `functions.firestore.document(...)` without `firebaseNode.initializeApp()`
  first.
* Editing `deploy/functions/index.js`: it is generated from `bin/main.dart`.
