import 'dart:async';
import 'dart:typed_data';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart'
    as node;
import 'package:tekartik_http/http.dart' as http;

class HttpResponseNode implements StreamSink<Uint8List>, http.HttpResponse {
  final ExpressHttpResponse expressHttpResponse;

  HttpResponseNode(this.expressHttpResponse);

  @override
  late int contentLength;

  @override
  late int statusCode;

  @override
  void add(Uint8List event) {
    // TODO: implement add
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: implement addError
  }

  @override
  Future addStream(Stream<Uint8List> stream) {
    // TODO: implement addStream
    throw UnimplementedError();
  }

  @override
  Future close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  // TODO: implement done
  Future get done => throw UnimplementedError();

  @override
  Future flush() {
    // TODO: implement flush
    throw UnimplementedError();
  }

  @override
  // TODO: implement headers
  HttpHeaders get headers => throw UnimplementedError();

  @override
  Future redirect(Uri location,
      {int status = http.httpStatusMovedTemporarily}) {
    // TODO: implement redirect
    throw UnimplementedError();
  }

  @override
  void write(Object? obj) {
    // TODO: implement write
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    // TODO: implement writeAll
  }

  @override
  void writeCharCode(int charCode) {
    // TODO: implement writeCharCode
  }

  @override
  void writeln([Object? object = '']) {
    // TODO: implement writeln
  }
}

class HttpRequestNode extends Stream<Uint8List> implements http.HttpRequest {
  final node.HttpsRequest nativeRequest;
  final node.HttpsResponse nativeResponse;

  HttpRequestNode(this.nativeRequest, this.nativeResponse);
  @override
  // TODO: implement contentLength
  int? get contentLength => throw UnimplementedError();

  @override
  // TODO: implement headers
  HttpHeaders get headers => throw UnimplementedError();

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }

  @override
  // TODO: implement method
  String get method => throw UnimplementedError();

  @override
  // TODO: implement requestedUri
  Uri get requestedUri => throw UnimplementedError();

  @override
  // TODO: implement response
  HttpResponse get response => throw UnimplementedError();

  @override
  // TODO: implement uri
  Uri get uri => throw UnimplementedError();
}

class ExpressHttpRequestNode extends ExpressHttpRequestWrapperBase
    implements ExpressHttpRequest {
  ExpressHttpRequestNode(
      node.HttpsRequest httpRequest, node.HttpsResponse httpResponse)
      : super(HttpRequestNode(httpRequest, httpResponse),
            Uri.parse(httpRequest.uri));

  @override
  dynamic get body => throw UnsupportedError('body');

  ExpressHttpResponse? _response;

  @override
  ExpressHttpResponse get response => _response ??=
      // ExpressHttpResponseNode(nativeInstance.response as NodeHttpResponse);
      throw UnsupportedError('response');
}

class ExpressHttpResponseNode extends ExpressHttpResponseWrapperBase
    implements ExpressHttpResponse {
  ExpressHttpResponseNode(super.implHttpResponse);
}
