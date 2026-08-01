@TestOn('node')
library;

import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart';
import 'package:tekartik_firebase_node/firebase_node.dart';
import 'package:test/test.dart';

var defaultRegion = regionUsCentral1;
String buildFolder = join('build', 'tekartik_firebase_function_node');

Future main() async {
  // ignore: invalid_use_of_do_not_submit_member
  debugFirebaseNode = true;
  group('https', () {
    test('HttpsError', () {
      var error = HttpsError('unknown', 'message', 'details');
      var jsError = error.toJS;
      expect(jsError.code, 'unknown');
    });
  });
}
