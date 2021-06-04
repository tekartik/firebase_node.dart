import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;
import 'package:tekartik_firebase_functions_node/src/express_http_request_node.dart';

import 'call_request_node.dart';
import 'firebase_functions_node.dart';

class HttpsFunctionsNode
    with common.HttpsFunctionsMixin
    implements common.HttpsFunctions {
  final FirebaseFunctionsNode functions;
  HttpsFunctionsNode(this.functions);

  @override
  common.HttpsFunction onRequest(common.RequestHandler handler) {
    void _handle(impl.ExpressHttpRequest request) {
      var _request = ExpressHttpRequestNode(request, request.uri);
      handler(_request);
    }

    return HttpsFunctionNode(functions.implFunctions.https.onRequest(_handle));
  }

  @override
  common.CallFunction onCall(common.CallHandler handler) {
    FutureOr<dynamic> _handle(
        dynamic data, impl.CallableContext context) async {
      try {
        var _request = CallRequestNode(data, context);
        return handler(_request);
      } on common.HttpsError catch (e) {
        throw impl.HttpsError(e.code, e.message, e.details);
      }
    }

    return CallFunctionNode(functions.implFunctions.https.onCall(_handle));
  }
}

class HttpsFunctionNode extends FirebaseFunctionNode
    implements common.HttpsFunction {
  // ignore: unused_field
  final dynamic _implCloudFonction;

  HttpsFunctionNode(this._implCloudFonction);

  @override
  dynamic get value => _implCloudFonction;

  @override
  String toString() => _implCloudFonction.toString();
}

class CallFunctionNode extends FirebaseFunctionNode
    implements common.CallFunction {
  // ignore: unused_field
  final dynamic _implCloudFonction;

  CallFunctionNode(this._implCloudFonction);

  @override
  dynamic get value => _implCloudFonction;

  @override
  String toString() => _implCloudFonction.toString();
}
