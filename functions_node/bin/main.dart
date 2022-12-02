import 'dart:async';

import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';

Future main() async {
  print('starting...');
  firebaseFunctionsUniversal['helloWorld'] =
      firebaseFunctionsUniversal.https.onRequest(helloWorld);
  // v2 function name(s) can only contain lower case letters, numbers, hyphens, and not exceed 62 characters in length
  firebaseFunctionsUniversal['helloworldv2'] =
      firebaseFunctionsUniversalV2.https.onRequest(helloWorld);
  await firebaseFunctionsUniversal.serve();
  print('serving...');
}

Future helloWorld(ExpressHttpRequest request) async {
  print('request.uri ${request.uri}');
  await request.response.send('2022-12-02 Hello');
}
