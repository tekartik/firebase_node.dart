import 'dart:async';
import 'dart:js_interop';

import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_auth/src/auth_mixin.dart';
import 'package:tekartik_firebase_auth/utils/json_utils.dart';
import 'package:tekartik_firebase_node/impl/firebase_node.dart';

import 'auth_node_js_interop.dart' as node;
import 'js_import.dart' as js;
// ignore_for_file: implementation_imports

class AuthServiceNode
    with FirebaseProductServiceMixin<FirebaseAuth>, AuthServiceMixin
    implements AuthService {
  @override
  bool get supportsListUsers => true;

  @override
  Auth auth(App app) {
    return getInstance(app, () {
      assert(app is AppNode, 'invalid firebase app type');
      final appNode = app as AppNode;
      return AuthNode(
        this,
        appNode,
        node.firebaseAdminAuthModule.getAuth(appNode.nativeInstance),
      );
    });
  }

  @override
  bool get supportsCurrentUser => false;
}

AuthServiceNode? _authServiceNode;

AuthServiceNode get authServiceNode => _authServiceNode ??= AuthServiceNode();

AuthService get authService => authServiceNode;

class ListUsersResultNode implements ListUsersResult {
  final node.ListUsersResult nativeInstance;

  ListUsersResultNode(this.nativeInstance);

  @override
  String get pageToken => nativeInstance.pageToken;

  @override
  List<UserRecord?> get users => nativeInstance.users
      .cast<node.UserRecord?>()
      .map(wrapUserRecord)
      .toList(growable: false);
}

class UserMetadataNode implements UserMetadata {
  final node.UserMetadata nativeInstance;

  UserMetadataNode(this.nativeInstance);

  @override
  String get creationTime => nativeInstance.creationTime;

  @override
  String get lastSignInTime => nativeInstance.creationTime;
}

class UserInfoNode implements UserInfo {
  final node.UserInfo nativeInstance;

  UserInfoNode(this.nativeInstance);

  @override
  String get displayName => nativeInstance.displayName;

  @override
  String get email => nativeInstance.email;

  @override
  String get phoneNumber => nativeInstance.phoneNumber;

  @override
  String get photoURL => nativeInstance.photoURL;

  @override
  String get providerId => nativeInstance.providerId;

  @override
  String get uid => nativeInstance.uid;
}

class UserRecordNode with FirebaseUserRecordDefaultMixin implements UserRecord {
  final node.UserRecord nativeInstance;

  UserRecordNode(this.nativeInstance);

  @override
  dynamic get customClaims => nativeInstance.customClaims;

  @override
  bool get disabled => nativeInstance.disabled;

  /// Can be null
  @override
  String? get displayName => nativeInstance.displayName;

  @override
  String? get email => nativeInstance.email;

  @override
  bool get emailVerified => nativeInstance.emailVerified;

  @override
  bool get isAnonymous => nativeInstance.isAnonymous;

  @override
  UserMetadata get metadata => wrapUserMetadata(nativeInstance.metadata)!;

  @override
  String get passwordHash => nativeInstance.passwordHash;

  @override
  String get passwordSalt => nativeInstance.passwordSalt;

  @override
  String get phoneNumber => nativeInstance.phoneNumber;

  @override
  String get photoURL => nativeInstance.photoURL;

  @override
  List<UserInfo> get providerData => nativeInstance.providerData
      .cast<node.UserInfo>()
      .map((nativeUserInfo) => wrapUserInfo(nativeUserInfo)!)
      .toList(growable: false);

  @override
  String get tokensValidAfterTime => nativeInstance.tokensValidAfterTime;

  @override
  String get uid => nativeInstance.uid;

  // user: UserRecordNode({uid: xxx, email: test@test.com})
  // - [object Object]
  // {uid: xxx, email: xxx@xxx.com, emailVerified: false,
  // displayName: null, photoURL: null, phoneNumber: null, disabled: false,
  // metadata: {creationTime: Thu, 13 Jun 2024 10:06:33 GMT,
  // lastSignInTime: null, lastRefreshTime: null},
  // providerData: [{uid: test@test.com, displayName: null, email: test@test.com,
  // photoURL: null, providerId: password, phoneNumber: null}],
  // passwordHash: xxx
  // passwordSalt: xxx==, tokensValidAfterTime: Thu, 13 Jun 2024 10:06:33 GMT,
  // tenantId: null}}
  @override
  String toString() =>
      'UserRecordNode(${userRecordToJson(this)}) - ${nativeInstance.dartify()} ${js.jsAnyToDebugString(nativeInstance)}}';
}

/// Node implementation
class DecodedIdTokenNode implements DecodedIdToken {
  final node.JSDecodedIdToken nativeInstance;

  DecodedIdTokenNode(this.nativeInstance);

  @override
  String get uid => nativeInstance.uid;
}

ListUsersResult? wrapListUsersResult(
  node.ListUsersResult? nativeListUsersResult,
) => nativeListUsersResult != null
    ? ListUsersResultNode(nativeListUsersResult)
    : null;

UserInfo? wrapUserInfo(node.UserInfo? nativeUserInfo) =>
    nativeUserInfo != null ? UserInfoNode(nativeUserInfo) : null;

UserRecord? wrapUserRecord(node.UserRecord? nativeUserRecord) =>
    nativeUserRecord != null ? UserRecordNode(nativeUserRecord) : null;

UserMetadata? wrapUserMetadata(node.UserMetadata? nativeUserMetadata) =>
    nativeUserMetadata != null ? UserMetadataNode(nativeUserMetadata) : null;

class AuthNode with FirebaseAppProductMixin<FirebaseAuth>, FirebaseAuthMixin {
  final AuthServiceNode serviceNode;
  final node.Auth nativeInstance;
  final AppNode appNode;
  AuthNode(this.serviceNode, this.appNode, this.nativeInstance);

  @override
  FirebaseApp get app => appNode;

  /// Retrieves a list of users (single batch only) with a size of [maxResults]
  /// and starting from the offset as specified by [pageToken].
  ///
  /// This is used to retrieve all the users of a specified project in batches.
  @override
  Future<ListUsersResult> listUsers({
    int? maxResults,
    String? pageToken,
  }) async {
    return wrapListUsersResult(
      await nativeInstance.listUsers(maxResults, pageToken),
    )!;
  }

  @override
  Future<UserRecord> getUserByEmail(String email) async =>
      wrapUserRecord(await nativeInstance.getUserByEmail(email))!;

  @override
  Future<UserRecord> getUser(String uid) async =>
      wrapUserRecord(await nativeInstance.getUser(uid))!;

  @override
  User get currentUser =>
      throw UnsupportedError('currentUser not supported for node');

  @override
  Stream<User> get onCurrentUser =>
      throw UnsupportedError('onCurrentUser not supported for node');

  @override
  Future<DecodedIdToken> verifyIdToken(
    String idToken, {
    bool? checkRevoked,
  }) async {
    var nativeDecodedIdToken = await nativeInstance.verifyIdToken(
      idToken,
      checkRevoked,
    );
    return DecodedIdTokenNode(nativeDecodedIdToken);
  }

  @override
  Future<User> reloadCurrentUser() =>
      throw UnsupportedError('reloadCurrentUser not supported for node');

  @override
  FirebaseAuthService get service => serviceNode;
}
