import 'dart:async';

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_firebase_functions_test/firebase_functions_test_runner.dart';
import 'package:tekartik_firebase_node/firebase_universal.dart';

Future main() async {
  // ignore: avoid_print
  print('starting...');
  firebaseUniversal.initializeApp();

  firebaseFunctionsUniversal['thelloworldv1'] = firebaseFunctionsUniversal.https
      .onRequest(helloWorld);

  // v2 function name(s) can only contain lower case letters, numbers, hyphens, and not exceed 62 characters in length
  firebaseFunctionsUniversal['thelloworldv2'] = firebaseFunctionsUniversal.https
      .onRequestV2(HttpsOptions(region: regionBelgium), helloWorld);

  firebaseFunctionsUniversal['thelloworldcorsv2'] = firebaseFunctionsUniversal
      .https
      .onRequestV2(HttpsOptions(region: regionBelgium, cors: true), helloWorld);

  if (kDartIsWeb) {
    initFunctionsBasic(firebaseFunctionsUniversal, prefix: 'node');
  } else {
    initFunctionsBasic(firebaseFunctionsUniversal, prefix: 'io');
  }
  await firebaseFunctionsUniversal.serve();
}

Future helloWorld(ExpressHttpRequest request) async {
  // ignore: avoid_print
  print('request.uri ${request.uri}');
  await request.response.send('2022-12-02 Hello');
}
