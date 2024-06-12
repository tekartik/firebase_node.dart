import 'dart:async';
import 'dart:js_interop' as js;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';

import 'firebase_node_js_interop.dart' as native;

FirebaseNode? _firebaseNode;

FirebaseAdmin get firebaseNode =>
    _firebaseNode ??= FirebaseNode._(native.admin);

class FirebaseAdminCredentialServiceNode
    implements FirebaseAdminCredentialService {
  final native.FirebaseAdmin nativeInstance;

  FirebaseAdminCredentialServiceNode(this.nativeInstance);

  @override
  FirebaseAdminCredential? applicationDefault() {
    var credential = nativeInstance.applicationDefault();
    return FirebaseAdminCredentialNode(credential);
  }

  @override
  void setApplicationDefault(FirebaseAdminCredential? credential) {
    throw UnsupportedError('setApplicationDefault not supported on node');
  }
}

class FirebaseAdminCredentialNode implements FirebaseAdminCredential {
  final native.Credential nativeInstance;

  FirebaseAdminCredentialNode(this.nativeInstance);

  @override
  Future<FirebaseAdminAccessToken> getAccessToken() async {
    var nativeToken =
        (await nativeInstance.getAccessToken().toDart) as native.AccessToken;
    return FirebaseAdminAccessTokenNode(nativeToken);
  }
}

class FirebaseAdminAccessTokenNode implements FirebaseAdminAccessToken {
  final native.AccessToken nativeInstance;

  FirebaseAdminAccessTokenNode(this.nativeInstance);

  @override
  String get data => nativeInstance.access_token;

  @override
  int get expiresIn => nativeInstance.expires_in.toInt();
}

//import 'package:firebase_functions_interop/
class FirebaseNode with FirebaseMixin implements FirebaseAdmin {
  FirebaseNode._(this.nativeInstance);

  final native.FirebaseAdmin nativeInstance;

  @override
  App initializeApp({AppOptions? options, String? name}) {
    // Invalid Firebase app options passed as the first argument to initializeApp() for the app named "test". Options must be a non-null object.
    // if options is null, it means we are using it in a server
    // hence no name...
    if (options == null) {
      name = null;
    }
    AppNode app;
    if (options == null) {
      app = AppNode(nativeInstance.initializeApp());
    } else if (name == null) {
      app = AppNode(nativeInstance.initializeApp(_unwrapAppOptions(options)));
    } else {
      app = AppNode(
          nativeInstance.initializeApp(_unwrapAppOptions(options), name));
    }
    _apps[name] = app;
    return app;
  }

  final _apps = <String?, AppNode>{};

  @override
  App app({String? name}) {
    return _apps[name]!;
  }

  FirebaseAdminCredentialServiceNode? _credentialService;

  @override
  FirebaseAdminCredentialService get credential =>
      _credentialService ??= FirebaseAdminCredentialServiceNode(native.admin);
}

native.AppOptions? _unwrapAppOptions(AppOptions? appOptions) {
  if (appOptions != null) {
    return native.AppOptions(
        databaseURL: appOptions.databaseURL,
        projectId: appOptions.projectId,
        storageBucket: appOptions.storageBucket);
  }
  return null;
}

AppOptions _wrapAppOptions(native.AppOptions nativeInstance) {
  return AppOptions(
      databaseURL: nativeInstance.databaseURL,
      projectId: nativeInstance.projectId,
      storageBucket: nativeInstance.storageBucket);
}

class AppNode with FirebaseAppMixin {
  final native.App nativeInstance;

  AppNode(this.nativeInstance);

  @override
  String get name => nativeInstance.name;

  @override
  Future delete() async {
    await nativeInstance.delete().toDart;
    await closeServices();
  }

  @override
  AppOptions get options => _wrapAppOptions(nativeInstance.options);
}