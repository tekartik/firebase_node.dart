# tekartik_firebase_functions_node

Cloud Functions for Firebase written in Dart with the
`tekartik_firebase_functions` api and compiled to Node.js (dart2js) over the
`firebase-functions` (v2) npm module. The same `bin/main.dart` also runs on
the Dart VM as a plain http server (`firebaseFunctionsUniversal`), to develop
and test the functions without node.

## Getting started

Not on pub.dev, add it as a git dependency, with the node build tools as dev
dependencies (see [doc/setup.md](doc/setup.md) for the `deploy/` folder and
the npm modules):

```yaml
dependencies:
  tekartik_firebase_functions_node:
    git:
      url: https://github.com/tekartik/firebase_node.dart
      path: functions_node
dev_dependencies:
  build_runner: ">=2.15.0"
  build_web_compilers: ">=4.7.0"
  tekartik_build_node:
    git:
      url: https://github.com/tekartik/build_node.dart
      path: packages/build_node
```

`bin/main.dart`:

```dart
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';

Future<void> main() async {
  var functions = firebaseFunctionsUniversal;
  functions.globalOptions = GlobalOptions(region: regionBelgium);
  functions['hello'] = functions.https.onRequest(
    (request) => request.response.send('Hello ${request.uri.path}'),
  );
  functions['echo'] = functions.https.onCall((request) => request.data);
  // No-op on node (the firebase cli loads the exported functions), an http
  // server on the VM (port 4999 by default).
  await functions.serve();
}
```

Compiled to `deploy/functions/index.js` (`gcfNodePackageBuild('.')` of
`tekartik_app_node_build`), it is served by the functions emulator or
deployed with the firebase cli.

## Platforms

* Node.js (dart2js): the deployed functions, `dart test -p node` (needs the
  npm modules of `package.json` installed in the package).
* Dart VM: `firebaseFunctionsUniversal` is an io http server
  (`tekartik_firebase_functions_http`), for local runs and tests.

## What to know

* Function names on node: lowercase letters, digits and hyphens (`helloworld`,
  not `helloWorld`).
* The options of a function only send what is set: without `region` it keeps
  the global region, a callable without `cors` keeps its default CORS (any
  origin), a `ScheduleOptions` without `timeoutSeconds` is valid.
* On node, a response is sent with `send` (or `redirect`): `write`,
  `writeln` and `add` are not implemented.
* A Firestore trigger (`firestore.document(path).onWrite`) needs the default
  app initialized first (`firebaseNode.initializeApp()`).

The agent skill
[tekartik-firebase-functions-node-setup](skills/tekartik-firebase-functions-node-setup/SKILL.md)
has more examples (scheduler, Firestore trigger, build and deploy tools,
emulator and VM tests).
