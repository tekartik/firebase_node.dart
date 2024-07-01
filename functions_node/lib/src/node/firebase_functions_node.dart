import 'dart:js_interop';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart'
    as node;
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart'
    as node;

import 'express_http_request_node.dart';
import 'firebase_functions_firestore_node.dart';
import 'firebase_functions_scheduler_node.dart';

final firebaseFunctionsNode = FirebaseFunctionsNode();

class FirebaseFunctionsNode
    with FirebaseFunctionsDefaultMixin
    implements FirebaseFunctions {
  final nativeInstance = node.firebaseFunctionsModule;

  @override
  void operator []=(String key, FirebaseFunction function) {
    nativeInstance[key] = (function as FirebaseFunctionNode).nativeInstance;
  }

  @override
  HttpsFunctions get https => HttpsFunctionsNode(this, nativeInstance.https);

  @override
  SchedulerFunctions get scheduler =>
      SchedulerFunctionsNode(this, nativeInstance.scheduler);

  @override
  late final firestore = FirestoreFunctionsNode(this, nativeInstance.firestore);

  @override
  late final params = _ParamsNode(this, nativeInstance.params);

  @override
  set globalOptions(GlobalOptions options) {
    nativeInstance.setGlobalOptions(options.toJS());
  }
}

class HttpsFunctionsNode with HttpsFunctionsMixin implements HttpsFunctions {
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
}

abstract class FirebaseFunctionNode implements FirebaseFunction {
  final FirebaseFunctionsNode firebaseFunctionsNode;

  FirebaseFunctionNode(this.firebaseFunctionsNode);

  node.JSFirebaseFunction get nativeInstance;
}

class HttpsFunctionNode extends FirebaseFunctionNode implements HttpsFunction {
  @override
  final node.JSHttpsFunction nativeInstance;

  HttpsFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
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

class _ParamsNode implements Params {
  final FirebaseFunctionsNode functions;
  final node.JSParams _params;

  _ParamsNode(this.functions, this._params);

  @override
  String get projectId => _params.projectID.value().toDart;
}

extension on GlobalOptions {
  node.JSGlobalOptions toJS() {
    return node.JSGlobalOptions(
        memory: memory,
        timeoutSeconds: timeoutSeconds,
        region: region,
        concurrency: concurrency);
  }
}
