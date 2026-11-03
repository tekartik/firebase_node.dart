@TestOn('node')
library;

import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:path/path.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart';
import 'package:tekartik_firebase_functions_node/src/node/global_options_node.dart';
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
  group('globalOptionsToNode', () {
    test('null values not set', () {
      // A null timeoutSeconds fails firebase-functions 7.3+.
      var options = globalOptionsToNode(GlobalOptions(region: regionBelgium));
      for (var name in [
        'timeoutSeconds',
        'memory',
        'concurrency',
        'maxInstances',
      ]) {
        expect(options.hasProperty(name.toJS).toDart, isFalse, reason: name);
      }
      expect(
        options.getProperty<js.JSString>('region'.toJS).toDart,
        regionBelgium,
      );
      expect(
        globalOptionsToNode(GlobalOptions()).hasProperty('region'.toJS).toDart,
        isFalse,
      );
    });
    test('values', () {
      var options = globalOptionsToNode(
        GlobalOptions(
          timeoutSeconds: 60,
          memory: runtimeOptionsMemory2GB,
          regions: [regionBelgium, regionUsCentral1],
        ),
      );
      expect(
        options.getProperty<js.JSNumber>('timeoutSeconds'.toJS).toDartInt,
        60,
      );
      expect(
        options.getProperty<js.JSString>('memory'.toJS).toDart,
        runtimeOptionsMemory2GB,
      );
      expect(
        options
            .getProperty<js.JSArray<js.JSString>>('region'.toJS)
            .toDart
            .map((region) => region.toDart),
        [regionBelgium, regionUsCentral1],
      );
    });
  });
}
