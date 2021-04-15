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
  await request.response.send('2020-09-09 Hello');
}
