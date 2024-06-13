import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;
import 'package:tekartik_firebase_functions_node/src/node_legacy/express_http_request_node.dart';
import 'package:tekartik_firebase_functions_node/src/node_legacy/import.dart';

import 'call_request_node.dart';
import 'firebase_functions_https_node.dart';
import 'firebase_functions_node_gen2.dart';

class HttpsFunctionsNodeV2
    with common.HttpsFunctionsMixin
    implements common.HttpsFunctions {
  final FirebaseFunctionsNodeGen2 functions;
  HttpsFunctionsNodeV2(this.functions);

  @Deprecated('Use onRequestV2')
  @override
  common.HttpsFunction onRequest(common.RequestHandler handler) {
    void handleRequest(impl.ExpressHttpRequest request) {
      var expressRequest = ExpressHttpRequestNode(request, request.uri);
      handler(expressRequest);
    }

    return HttpsFunctionNode(
        functions.implFunctions.https.onRequest(handleRequest));
  }

  @override
  common.HttpsFunction onRequestV2(
      common.HttpsOptions httpsOptions, common.RequestHandler handler) {
    void handleRequest(impl.ExpressHttpRequest request) {
      var expressRequest = ExpressHttpRequestNode(request, request.uri);
      handler(expressRequest);
    }

    return HttpsFunctionNode(functions.implFunctions.https.onRequestV2(
        impl.HttpsOptions(
            region: httpsOptions.region ?? httpsOptions.regions,
            cors: httpsOptions.cors),
        handleRequest));
  }

  @override
  common.CallFunction onCall(common.CallHandler handler) {
    Future<dynamic> handleCall(
        dynamic data, impl.CallableContext context) async {
      try {
        var callRequest = CallRequestNode(data, context);
        return await handler(callRequest);
      } on common.HttpsError catch (e) {
        throw impl.HttpsError(e.code, e.message, e.details);
      }
    }

    return CallFunctionNode(functions.implFunctions.https.onCall(handleCall));
  }
}
