# Setup

- Follow the [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build) instructions
- Add `firebase_functions` dependencies:
  ```yaml
  tekartik_firebase_functions_node:
    git:
      url: git://github.com/tekartik/firebase_functions.dart
      path: firebase_functions_node
      ref: dart2
    version: '>=0.2.1'
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