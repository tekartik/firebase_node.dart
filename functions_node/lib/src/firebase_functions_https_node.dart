import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;
import 'package:tekartik_firebase_functions_node/src/express_http_request_node.dart';

import 'firebase_functions_node.dart';

class HttpsFunctionsNode implements common.HttpsFunctions {
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
}

class HttpsFunctionNode extends FirebaseFunctionNode
    implements common.HttpsFunction {
  // ignore: unused_field
  final _implCloudFonction;

  HttpsFunctionNode(this._implCloudFonction);

  @override
  dynamic get value => _implCloudFonction;

  @override
  String toString() => _implCloudFonction.toString();
}
