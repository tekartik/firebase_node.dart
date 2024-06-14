import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart'
    as node;
import 'package:tekartik_http/http.dart' as http;

import 'import_http.dart';
import 'import_node.dart' as js;

class ExpressHttpRequestNode implements ExpressHttpRequest {
  final node.JSHttpsRequest nativeHttpRequest;
  final node.JSHttpsResponse nativeHttpResponse;
  ExpressHttpRequestNode(this.nativeHttpRequest, this.nativeHttpResponse);

  @override
  Uint8List get body {
    var rawBody = nativeHttpRequest.rawBody;
    if (rawBody == null) {
      return Uint8List.fromList([]);
    }
    return rawBody.toDart;
  }

  @override
  late final ExpressHttpResponse response =
      ExpressHttpResponseNode(nativeHttpResponse);

  @override
  late final headers = () {
    var headers = HttpHeadersMemory();
    var rawHeaders = nativeHttpRequest.headers;
    if (rawHeaders.isA<js.JSObject>()) {
      var jsHeaders = rawHeaders as js.JSObject;
      for (var key in js.jsObjectKeys(jsHeaders)) {
        var value = jsHeaders.getProperty(key.toJS);
        if (value.isA<js.JSArray>()) {
          var values = (value as js.JSArray)
              .toDart
              .map((e) => (e as js.JSString).toDart);
          for (var value in values) {
            headers.add(key.toString(), value);
          }
        } else if (value.isA<js.JSString>()) {
          headers.add(key.toString(), (value as js.JSString).toDart);
        }
      }
    }
    return headers;
  }();

  @override
  String get method => nativeHttpRequest.method;

  @override
  Uri get requestedUri => uri;

  @override
  Uri get uri => Uri.parse(nativeHttpRequest.url);
}

class ExpressHttpResponseNode implements ExpressHttpResponse {
  node.JSHttpsResponse nativeHttpResponse;

  var _closed = false;

  ExpressHttpResponseNode(this.nativeHttpResponse);

  @override
  int statusCode = http.httpStatusCodeOk;

  @override
  late final HttpHeaders headers = HttpHeadersMemory();

  void _sendHeaderAndStatus() {
    nativeHttpResponse = nativeHttpResponse.status(statusCode);
    headers.forEach((name, values) {
      if (values.length > 1) {
        nativeHttpResponse = nativeHttpResponse.setHeaderList(name, values);
      } else {
        nativeHttpResponse =
            nativeHttpResponse.setHeader(name, values.firstOrNull ?? '');
      }
    });
  }

  @override
  Future<void> send([Object? body]) async {
    _sendHeaderAndStatus();
    js.JSAny? jsBody;
    // Do everything here!
    if (body is Uint8List) {
      jsBody = body.toJS;
    } else if (body is String) {
      jsBody = body.toJS;
    } else if (body is List<int>) {
      jsBody = asUint8List(body).toJS;
    } else if (body is Map || body is List) {
      jsBody = jsonEncode(body).toJS;
    } else {
      throw 'body ${body?.runtimeType} not supported';
    }
    nativeHttpResponse.send(jsBody);

    _closed = true;
  }

  @override
  void add(Uint8List bytes) {
    throw UnimplementedError('ExpressHttpResponseNode.add');
  }

  @override
  Future close() async {
    if (!_closed) {
      _closed = true;
      try {
        _sendHeaderAndStatus();
        nativeHttpResponse.end();
      } catch (e) {
        print('error closing response $e');
      }
    }
  }

  @override
  Future redirect(Uri location, {int? status}) {
    throw UnimplementedError('ExpressHttpResponseNode.redirect');
  }

  @override
  void write(String content) {
    throw UnimplementedError('ExpressHttpResponseNode.write');
  }

  @override
  void writeln(String content) {
    throw UnimplementedError('ExpressHttpResponseNode.writeln');
  }
}
