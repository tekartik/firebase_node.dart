import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_http_node/src/http_server_node.dart'; // ignore: implementation_imports
import 'package:tekartik_http_node/src/node/http_server.dart'; // ignore: implementation_imports

import 'import_node.dart';

class ExpressHttpRequestNode extends ExpressHttpRequestWrapperBase
    implements ExpressHttpRequest {
  impl.ExpressHttpRequest get nativeInstance =>
      (implHttpRequest as HttpRequestNode).nodeHttpRequest
          as impl.ExpressHttpRequest;

  ExpressHttpRequestNode(impl.ExpressHttpRequest httpRequest, Uri rewrittenUri)
      : super(HttpRequestNode(httpRequest), rewrittenUri);

  @override
  dynamic get body => nativeInstance.body;

  ExpressHttpResponse? _response;

  @override
  ExpressHttpResponse get response => _response ??=
      ExpressHttpResponseNode(nativeInstance.response as NodeHttpResponse);
}

class ExpressHttpResponseNode extends ExpressHttpResponseWrapperBase
    implements ExpressHttpResponse {
  ExpressHttpResponseNode(super.implHttpResponse);
}
