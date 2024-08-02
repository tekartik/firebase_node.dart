import 'dart:async';
import 'dart:js_interop' as js;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';

import 'firebase_node_js_interop.dart' as native;

FirebaseNode? _firebaseNode;

/// The firebase node implementation
FirebaseAdmin get firebaseNode =>
    _firebaseNode ??= FirebaseNode._(native.firebaseAdminModule);

/// Extension to create a FirebaseAppOptions from a service account map
extension FirebaseNodeAppOptionsExt on FirebaseAppOptions {
  /// Create a FirebaseAppOptions from a service account map
  FirebaseAppOptions withServiceAccountMap(
      Map<String, Object?> serviceAccountMap) {
    return FirebaseAppOptionsNode(serviceAccountMap,
        storageBucket: storageBucket);
  }
}

/// Firebase node options
class FirebaseAppOptionsNode
    with FirebaseAppOptionsMixin
    implements FirebaseAppOptions {
  // {
  //   "type": "service_account",
  //   "project_id": "xxxx-free-dev",
  //   "private_key_id": "xxx",
  //   "private_key": "-----BEGIN PRIVATE KEY-----\nMI=\n-----END PRIVATE KEY-----\n",
  //   "client_email": "xxx@xxx.iam.gserviceaccount.com",
  //   "client_id": "xxx",
  //   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //   "token_uri": "https://accounts.google.com/o/oauth2/token",
  //   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  //   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/x%40x.iam.gserviceaccount.com"
  // }
  /// The service account map
  final Map<String, Object?> serviceAccountMap;

  /// Constructor
  FirebaseAppOptionsNode(this.serviceAccountMap, {String? storageBucket})
      : _storageBucket = storageBucket;

  /// The client email
  String get clientEmail {
    return serviceAccountMap['client_email'] as String;
  }

  /// The private key
  String get privateKey {
    return serviceAccountMap['private_key'] as String;
  }

  @override
  String get projectId {
    return serviceAccountMap['project_id'] as String;
  }

  @override
  String get storageBucket => _storageBucket ??= '$projectId.appspot.com';
  String? _storageBucket;
}

/// Create a FirebaseAppOptions from a service account map
FirebaseAppOptions firebaseNodeAppOptionsFromServiceAccountMap(
    Map<String, Object?> serviceAccountMap) {
  return FirebaseAppOptionsNode(serviceAccountMap);
}

/// Firebase node credential service
class FirebaseAdminCredentialServiceNode
    implements FirebaseAdminCredentialService {
  /// Native instance
  final native.FirebaseAdminModule nativeInstance;

  /// Constructor
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

/// Firebase node credential
class FirebaseAdminCredentialNode implements FirebaseAdminCredential {
  /// Native instance
  final native.Credential nativeInstance;

  /// Constructor
  FirebaseAdminCredentialNode(this.nativeInstance);

  @override
  Future<FirebaseAdminAccessToken> getAccessToken() async {
    var nativeToken =
        (await nativeInstance.getAccessToken().toDart) as native.AccessToken;
    return FirebaseAdminAccessTokenNode(nativeToken);
  }
}

/// Firebase node access token
class FirebaseAdminAccessTokenNode implements FirebaseAdminAccessToken {
  /// Native instance
  final native.AccessToken nativeInstance;

  /// Constructor
  FirebaseAdminAccessTokenNode(this.nativeInstance);

  @override
  String get data => nativeInstance.access_token;

  @override
  int get expiresIn => nativeInstance.expires_in.toInt();
}

const _nameDefault = '[DEFAULT]';

/// Firebase node implementation
class FirebaseNode with FirebaseMixin implements FirebaseAdmin {
  FirebaseNode._(this.nativeInstance);

  /// Native instance
  final native.FirebaseAdminModule nativeInstance;

  @override
  FirebaseApp initializeApp({AppOptions? options, String? name}) {
    // Invalid Firebase app options passed as the first argument to initializeApp() for the app named "test". Options must be a non-null object.
    // if options is null, it means we are using it in a server
    // hence no name...
    if (options == null) {
      name = null;
    }
    var nativeOptions = _unwrapAppOptions(this, options);
    AppNode app;
    if (nativeOptions == null) {
      app = AppNode(this, nativeInstance.initializeApp());
    } else if (name == null) {
      app = AppNode(this, nativeInstance.initializeApp(nativeOptions));
    } else {
      app = AppNode(this, nativeInstance.initializeApp(nativeOptions, name));
    }
    _apps[name ?? _nameDefault] =
        FirebaseMixin.latestFirebaseInstanceOrNull = app;
    return app;
  }

  final _apps = <String?, AppNode>{};

  @override
  App app({String? name}) {
    return _apps[name ?? _nameDefault]!;
  }

  FirebaseAdminCredentialServiceNode? _credentialService;

  @override
  FirebaseAdminCredentialService get credential => _credentialService ??=
      FirebaseAdminCredentialServiceNode(native.firebaseAdminModule);
}

native.AppOptions? _unwrapAppOptions(
    FirebaseNode firebaseNode, FirebaseAppOptions? appOptions) {
  if (appOptions is FirebaseAppOptionsNode) {
    var projectId = appOptions.projectId;
    var storageBucket = appOptions.storageBucket;
    return native.AppOptions(
      credential: firebaseNode.nativeInstance.serviceAccountCredential(
          native.ServiceAccount(
              projectId: projectId,
              clientEmail: appOptions.clientEmail,
              privateKey: appOptions.privateKey)),
      //databaseURL: appOptions.databaseURL,
      projectId: projectId,
      storageBucket: storageBucket,
      //    storageBucket: appOptions.storageBucket
    );
  }
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

/// Compat
typedef AppNode = FirebaseAppNode;

/// Firebase node app
class FirebaseAppNode with FirebaseAppMixin {
  /// Firebase node
  final FirebaseNode firebaseNode;

  /// Native instance
  final native.App nativeInstance;

  /// Constructor
  FirebaseAppNode(this.firebaseNode, this.nativeInstance);

  @override
  Firebase get firebase => firebaseNode;

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
