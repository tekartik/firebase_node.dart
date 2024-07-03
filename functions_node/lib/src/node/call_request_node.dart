import 'dart:js_interop';

import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_auth_node/src/node/auth_node.dart' // ignore: implementation_imports
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart'
    as js;

class CallRequestNode with CallRequestMixin implements CallRequest {
  final js.JSCallableRequest nativeInstance;

  @override
  late final Object? data = nativeInstance.data?.dartify();

  @override
  late final CallContext context = CallContextNode(nativeInstance);

  CallRequestNode(this.nativeInstance);
}

class CallContextNode with CallContextMixin implements CallContext {
  final js.JSCallableRequest nativeInstance;

  CallContextNode(this.nativeInstance);

  @override
  late final CallContextAuth? auth = CallContextAuthNode(nativeInstance);
}

class CallContextAuthNode with CallContextAuthMixin implements CallContextAuth {
  final js.JSCallableRequest nativeInstance;

  CallContextAuthNode(this.nativeInstance);

  @override
  String? get uid => nativeInstance.auth.uid;

  @override
  DecodedIdToken? get token {
    return impl.DecodedIdTokenNode(nativeInstance.auth.token);
  }
}
