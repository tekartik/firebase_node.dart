@TestOn('node')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase_storage_node/src/node/storage_node.dart';
import 'package:tekartik_firebase_storage_node/src/node/storage_node_js_interop.dart'
    as node;
import 'package:test/test.dart';

/// A native file metadata holding the given fields only.
node.FileMetadata _metadata(Map<String, String> fields) {
  var object = JSObject();
  fields.forEach((key, value) => object[key] = value.toJS);
  return object as node.FileMetadata;
}

void main() {
  group('metadata', () {
    test('fields', () {
      var metadata = FileMetadataNode(
        _metadata({
          'size': '40',
          'updated': '2020-11-24T11:41:47.752Z',
          'md5Hash': '9iamz8697RUaZ/je/alxAg==',
          'contentType': 'text/plain',
        }),
      );
      expect(metadata.size, 40);
      expect(metadata.md5Hash, '9iamz8697RUaZ/je/alxAg==');
      expect(metadata.contentType, 'text/plain');
      expect(metadata.cacheControl, isNull);
      expect(
        metadata.dateUpdated.toUtc().toIso8601String(),
        '2020-11-24T11:41:47.752Z',
      );
    });

    test('no md5Hash (composite object)', () {
      // GCS gives no md5Hash for a composite object (compose, parallel
      // composite uploads): the getter threw "type 'JSNull' is not a subtype
      // of type 'String'".
      var metadata = FileMetadataNode(
        _metadata({'size': '40', 'updated': '2020-11-24T11:41:47.752Z'}),
      );
      expect(metadata.md5Hash, '');
      expect(metadata.toString(), contains('size: 40'));
    });
  });
}
