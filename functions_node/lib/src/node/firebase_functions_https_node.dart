import 'dart:js_interop' as js;

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart'
    as node;

import 'call_request_node.dart';
import 'express_http_request_node.dart';
import 'firebase_functions_node.dart';

class HttpsFunctionsNode
    with HttpsFunctionsDefaultMixin
    implements HttpsFunctions {
  final FirebaseFunctionsNode functions;
  final node.JSHttpsFunctions nativeInstance;

  HttpsFunctionsNode(this.functions, this.nativeInstance);

  @override
  HttpsFunction onRequest(RequestHandler handler,
      {HttpsOptions? httpsOptions}) {
    void handleRequest(
        node.JSHttpsRequest request, node.JSHttpsResponse response) {
      var expressRequest = ExpressHttpRequestNode(request, response);
      handler(expressRequest);
    }

    return HttpsFunctionNode(
        functions,
        nativeInstance.onRequest(
            options: toNodeHttpsOptionsOrNull(httpsOptions),
            handler: handleRequest));
  }

  @override
  HttpsCallableFunction onCall(CallHandler handler,
      {HttpsCallableOptions? callableOptions}) {
    FutureOr<Object?> handleCall(node.JSCallableRequest request) async {
      var requestNode = CallRequestNode(request);
      try {
        return await handler(requestNode);
      } on HttpsError catch (e) {
        // TODO handle error
        print('error: ${e.code} ${e.message} ${e.details}');
        throw e.toJS.dartify()!;
      }
    }

    return HttpsCallableFunctionNode(
        functions,
        nativeInstance.onCall(
            options: toNodeCallableOptionsOrNull(callableOptions),
            handler: handleCall));
  }
}

class HttpsFunctionNode extends FirebaseFunctionNode implements HttpsFunction {
  @override
  final node.JSHttpsFunction nativeInstance;

  HttpsFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

class HttpsCallableFunctionNode extends FirebaseFunctionNode
    implements HttpsCallableFunction {
  @override
  final node.JSCallableFunction nativeInstance;

  HttpsCallableFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

node.JSHttpsOptions? toNodeHttpsOptionsOrNull(HttpsOptions? httpsOptions) {
  if (httpsOptions == null) {
    return null;
  }
  return toNodeHttpsOptions(httpsOptions);
}

node.JSHttpsOptions toNodeHttpsOptions(HttpsOptions httpsOptions) {
  return node.JSHttpsOptions(
      region: httpsOptions.region, cors: httpsOptions.cors?.toJS);
}

node.JSCallableOptions? toNodeCallableOptionsOrNull(
    HttpsCallableOptions? callableOptions) {
  if (callableOptions == null) {
    return null;
  }
  return toNodeCallableOptions(callableOptions);
}

node.JSCallableOptions toNodeCallableOptions(
    HttpsCallableOptions callableOptions) {
  return node.JSCallableOptions(
      consumeAppCheckToken: callableOptions.consumeAppCheckToken,
      enforceAppCheck: callableOptions.enforceAppCheck,
      region: callableOptions.region,
      cors: callableOptions.cors?.toJS);
}

/// To throw as a JS object
extension on HttpsError {
  node.JSHttpsError get toJS {
    js.JSAny? jsDetails;
    try {
      jsDetails = details?.jsify();
    } catch (e) {
      jsDetails = details?.toString().toJS;
    }

    return node.JSHttpsError(code: code, message: message, details: jsDetails);
  }
}
