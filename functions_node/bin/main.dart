import 'dart:async';

import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';

Future main() async {
  print('starting...');
  firebaseFunctionsUniversal['thelloworldv1'] =
      firebaseFunctionsUniversal.https.onRequest(helloWorld);
  // v2 function name(s) can only contain lower case letters, numbers, hyphens, and not exceed 62 characters in length
  firebaseFunctionsUniversal['thelloworldv2'] = firebaseFunctionsUniversal.https
      .onRequestV2(HttpsOptions(region: regionBelgium), helloWorld);
  firebaseFunctionsUniversal['thelloworldcorsv2'] = firebaseFunctionsUniversal
      .https
      .onRequestV2(HttpsOptions(region: regionBelgium, cors: true), helloWorld);
  await firebaseFunctionsUniversal.serveUniversal();
  print('serving...');
}

Future helloWorld(ExpressHttpRequest request) async {
  print('request.uri ${request.uri}');
  await request.response.send('2022-12-02 Hello');
}
