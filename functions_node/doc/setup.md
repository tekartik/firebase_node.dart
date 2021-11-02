# Setup

- Follow the [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build) instructions
- Add `firebase_functions` dependencies:
  ```yaml
  dependencies:
    tekartik_firebase_functions_node:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: functions_node
        ref: dart2_3
      version: '>=0.2.1'
  ```
- Add `dev_dependencies`:
  ```yaml
  dev_dependencies:
    # needed node dependencies
    build_web_compilers:
    build_runner:
    tekartik_build_node:
      git:
      url: https://github.com/tekartik/build_node.dart
      path: packages/build_node
      ref: dart2_3
  ```
- `bin/main.dart`

```dart
import 'dart:async';

import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';

Future main() async {
  print('starting...');
  firebaseFunctionsUniversal['helloWorld'] =
      firebaseFunctions.https.onRequest(helloWorld);
  await firebaseFunctionsUniversal.serve();
  print('serving...');
}

Future helloWorld(ExpressHttpRequest request) async {
  print('request.uri ${request.uri}');
  await request.response.send('Hello');
}
```


- Add `deploy/functions/package.json` and run `npm install on it`
```shell
cd deploy/functions
npm install firebase-functions@latest firebase-admin@latest --save
```