# Setup

- Follow the [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build)
  instructions.
- Add the dependencies:
  ```yaml
  dependencies:
    tekartik_firebase_functions_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: functions_node
  dev_dependencies:
    # needed node dependencies
    build_web_compilers: ">=4.7.0"
    build_runner: ">=2.15.0"
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
    tekartik_app_node_build:
      git:
        url: https://github.com/tekartik/app_node_utils.dart
        path: app_build
  ```
- `build.yaml`, compiling `bin/` with dart2js:
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
- `bin/main.dart`:

```dart
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';

Future<void> main() async {
  firebaseFunctionsUniversal['hello'] = firebaseFunctionsUniversal.https
      .onRequest(helloWorld);
  // No-op on node, an http server on the VM.
  await firebaseFunctionsUniversal.serve();
}

Future<void> helloWorld(ExpressHttpRequest request) async {
  await request.response.send('Hello');
}
```

- Add `deploy/firebase.json` (functions `source: functions`) and
  `deploy/functions/package.json` (`"main": "index.js"`, the `firebase-admin`
  and `firebase-functions` npm modules), then install them:
  ```shell
  cd deploy/functions
  npm install firebase-functions@latest firebase-admin@latest --save
  ```
- In `deploy`, select the project: `firebase use --add <firebase-project-id>`.
- Build `deploy/functions/index.js` with `gcfNodePackageBuild('.')`
  (`package:tekartik_app_node_build/gcf_build.dart`), serve it with
  `gcfNodePackageServeFunctions('.')` (the functions emulator) or deploy it
  with `gcfNodePackageDeployFunctions('.', projectId: ...)`.
