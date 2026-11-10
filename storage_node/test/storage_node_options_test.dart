@TestOn('node')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase_storage/storage.dart';
import 'package:tekartik_firebase_storage_node/src/node/storage_node.dart';
import 'package:test/test.dart';

bool _has(JSObject object, String name) => object.hasProperty(name.toJS).toDart;

void main() {
  group('options', () {
    test('get files options without maxResults or pageToken', () {
      // A null maxResults was sent as `maxResults=`: the storage API answered
      // "Invalid unsigned integer value: ''".
      var options = storageNodeGetFilesOptions(
        GetFilesOptions(prefix: 'dir/', autoPaginate: false),
      )!;
      expect(_has(options, 'maxResults'), isFalse);
      expect(_has(options, 'pageToken'), isFalse);
      expect((options['prefix'] as JSString).toDart, 'dir/');
      expect((options['autoPaginate'] as JSBoolean).toDart, isFalse);
    });

    test('get files options set', () {
      var options = storageNodeGetFilesOptions(
        GetFilesOptions(
          maxResults: 2,
          prefix: 'dir/',
          autoPaginate: true,
          pageToken: 'token',
        ),
      )!;
      expect((options['maxResults'] as JSNumber).toDartInt, 2);
      expect((options['pageToken'] as JSString).toDart, 'token');
      expect((options['autoPaginate'] as JSBoolean).toDart, isTrue);
    });

    test('save options without content type', () {
      var options = storageNodeFileSaveOptions(
        StorageUploadFileOptions(cacheControl: 'no-cache'),
      )!;
      expect(_has(options, 'contentType'), isFalse);
      var metadata = options['metadata'] as JSObject;
      expect((metadata['cacheControl'] as JSString).toDart, 'no-cache');
    });

    test('save options without cache control', () {
      var options = storageNodeFileSaveOptions(
        StorageUploadFileOptions(contentType: 'text/plain'),
      )!;
      expect(_has(options, 'metadata'), isFalse);
      expect((options['contentType'] as JSString).toDart, 'text/plain');
    });
  });
}
