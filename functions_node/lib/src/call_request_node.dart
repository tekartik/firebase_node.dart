import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_auth_node/src/auth_node.dart' // ignore: implementation_imports
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart';

class CallRequestNode with CallRequestMixin implements CallRequest {
  @override
  final Object? data;

  @override
  late final CallContext context;

  CallRequestNode(this.data, impl.CallableContext? callableContext) {
    context = CallContextNode(callableContext);
  }

  @override
  String? get text => data?.toString();
}

class CallContextNode with CallContextMixin implements CallContext {
  final impl.CallableContext? nativeInstance;

  CallContextNode(this.nativeInstance);

  @override
  late final CallContextAuth? auth = CallContextAuthNode(nativeInstance);
}

class CallContextAuthNode with CallContextAuthMixin implements CallContextAuth {
  final impl.CallableContext? nativeInstance;

  CallContextAuthNode(this.nativeInstance);

  @override
  String? get uid => nativeInstance?.authUid;

  @override
  DecodedIdToken? get token {
    if (nativeInstance?.authToken == null) {
      return null;
    }
    return impl.DecodedIdTokenNode(nativeInstance!.authToken!);
  }
}
