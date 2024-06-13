import 'dart:js_interop';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_http/firebase_functions_http.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart'
    as node;

import 'express_http_request_node.dart';

final firebaseFunctionsNode = FirebaseFunctionsNode();

class FirebaseFunctionsNode extends FirebaseFunctionsHttp {
  final nativeInstance = node.firebaseFunctionsModule;
  @override
  void operator []=(String key, FirebaseFunction function) {
    nativeInstance[key] = (function as FirebaseFunctionNode).nativeInstance;
  }

  @override
  HttpsFunctions get https => HttpsFunctionsNode(this, nativeInstance.https);
}

class HttpsFunctionsNode with HttpsFunctionsMixin implements HttpsFunctions {
  final FirebaseFunctionsNode functions;
  final node.HttpsFunctions nativeInstance;
  HttpsFunctionsNode(this.functions, this.nativeInstance);

  @override
  HttpsFunction onRequest(RequestHandler handler) {
    return onRequestV2(HttpsOptions(), handler);
  }

  @override
  HttpsFunction onRequestV2(HttpsOptions httpsOptions, RequestHandler handler) {
    void handleRequest(node.HttpsRequest request, node.HttpsResponse response) {
      var expressRequest = ExpressHttpRequestNode(request, response);
      handler(expressRequest);
    }

    return HttpsFunctionNode(
        functions,
        nativeInstance.onRequest(
            options: toNodeHttpsOptions(httpsOptions), handler: handleRequest));

    //throw UnimplementedError('onRequestV2');
  }
} /*

class ExpressHttpRequestNode extends ExpressHttpRequestWrapperBase
    implements ExpressHttpRequest {
  node.HttpsRequest get nativeInstance =>
      (implHttpRequest as HttpsRequestNode).nodeHttpRequest
          as impl.ExpressHttpRequest;

  ExpressHttpRequestNode(ExpressHttpRequest httpRequest, Uri rewrittenUri)
      : super(HttpRequestNode(httpRequest), rewrittenUri);

  @override
  dynamic get body => nativeInstance.body;

  ExpressHttpResponse? _response;

  @override
  ExpressHttpResponse get response => _response ??=
      ExpressHttpResponseNode(nativeInstance.response as NodeHttpResponse);
}*/

class ExpressHttpResponseNode extends ExpressHttpResponseWrapperBase
    implements ExpressHttpResponse {
  ExpressHttpResponseNode(super.implHttpResponse);
}

class HttpsFunctionNode extends FirebaseFunctionNode implements HttpsFunction {
  @override
  final node.HttpsFunction nativeInstance;

  HttpsFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

abstract class FirebaseFunctionNode implements FirebaseFunction {
  final FirebaseFunctionsNode firebaseFunctionsNode;

  FirebaseFunctionNode(this.firebaseFunctionsNode);
  node.FirebaseFunction get nativeInstance;
}

node.HttpsOptions toNodeHttpsOptions(HttpsOptions httpsOptions) {
  return node.HttpsOptions(
      region: httpsOptions.region, cors: httpsOptions.cors?.toJS);
}
