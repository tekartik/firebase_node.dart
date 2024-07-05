@TestOn('node')
library tekartik_gcloud_pubsub_node_lib_src;

import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:tekartik_pubsub_node/src/pubsub_bindings.dart';
import 'package:test/test.dart';

void main() {
  group('pubsub_node', () {
    test('First Test', () {
      print(jsObjectKeys(pubsubJs));
    });
  });
}
