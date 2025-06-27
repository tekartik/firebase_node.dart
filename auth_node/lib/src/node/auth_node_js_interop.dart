// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop' as js;

import 'node_import.dart';

/// The Firebase Auth service interface.
final firebaseAdminAuthModule = () {
  return authModule = require<AuthModule>('firebase-admin/auth');
}();

/// First loaded wins
late AuthModule authModule;
extension type AuthModule._(js.JSObject _) implements js.JSObject {}

extension AuthModuleExt on AuthModule {
  /// getAuth() can be called with no arguments to access the default app's Auth
  /// service or as getAuth(app) to access the Auth service associated with a specific app.
  //
  /// Signature:
  ///   export declare function getAuth(app?: App): Auth;
  external Auth getAuth([App? app]);
}

extension type Auth._(js.JSObject _) implements js.JSObject {}

extension AuthExt on Auth {
  /// The app associated with this Auth service instance.
  external App get app;

  /// Creates a new Firebase custom token (JWT) that can be sent back to a client
  /// device to use to sign in with the client SDKs' signInWithCustomToken()
  /// methods.
  ///
  /// Returns a js.JSPromise fulfilled with a custom token string for the provided uid
  /// and payload.
  @js.JS('createCustomToken')
  external js.JSPromise<js.JSString> jsCreateCustomToken(
    String uid,
    js.JSObject? developerClaims,
  );

  /// Creates a new user.
  ///
  /// Returns a js.JSPromise fulfilled with [UserRecord] corresponding to the newly
  /// created user.
  @js.JS('createUser')
  external js.JSPromise<UserRecord> jsCreateUser(CreateUserRequest properties);

  /// Deletes an existing user.
  ///
  /// Returns a js.JSPromise containing `void`.
  @js.JS('deleteUser')
  external js.JSPromise jsDeleteUser(String uid);

  /// Gets the user data for the user corresponding to a given [uid].
  ///
  /// Returns a js.JSPromise fulfilled with [UserRecord] corresponding to the provided
  /// [uid].
  @js.JS('getUser')
  external js.JSPromise<UserRecord> jsGetUser(String uid);

  /// Gets the user data for the user corresponding to a given [email].
  ///
  /// Returns a js.JSPromise fulfilled with [UserRecord] corresponding to the provided
  /// [email].
  @js.JS('getUserByEmail')
  external js.JSPromise<UserRecord> jsGetUserByEmail(String email);

  /// Gets the user data for the user corresponding to a given [phoneNumber].
  ///
  /// Returns a js.JSPromise fulfilled with [UserRecord] corresponding to the provided
  /// [phoneNumber].
  @js.JS('getUserByPhoneNumber')
  external js.JSPromise<UserRecord> jsGetUserByPhoneNumber(String phoneNumber);

  /// Retrieves a list of users (single batch only) with a size of [maxResults]
  /// and starting from the offset as specified by [pageToken].
  ///
  /// This is used to retrieve all the users of a specified project in batches.
  ///
  /// Returns a js.JSPromise that resolves with the current batch of downloaded users
  /// and the next page token as an instance of [ListUsersResult].
  @js.JS('listUsers')
  external js.JSPromise<ListUsersResult> jsListUsers([
    int? maxResults,
    String? pageToken,
  ]);

  /// Revokes all refresh tokens for an existing user.
  ///
  /// This API will update the user's [UserRecord.tokensValidAfterTime] to the
  /// current UTC. It is important that the server on which this is called has
  /// its clock set correctly and synchronized.
  ///
  /// While this will revoke all sessions for a specified user and disable any
  /// new ID tokens for existing sessions from getting minted, existing ID tokens
  /// may remain active until their natural expiration (one hour). To verify that
  /// ID tokens are revoked, use [AuthModule.verifyIdToken] where `checkRevoked` is set
  /// to `true`.
  ///
  /// Returns a js.JSPromise containing `void`.
  @js.JS('revokeRefreshTokens')
  external js.JSPromise jsRevokeRefreshTokens(String uid);

  /// Sets additional developer claims on an existing user identified by the
  /// provided uid, typically used to define user roles and levels of access.
  ///
  /// These claims should propagate to all devices where the user is already
  /// signed in (after token expiration or when token refresh is forced) and the
  /// next time the user signs in. If a reserved OIDC claim name is used
  /// (sub, iat, iss, etc), an error is thrown. They will be set on the
  /// authenticated user's ID token JWT.
  ///
  /// [customUserClaims] can be `null`.
  ///
  /// Returns a js.JSPromise containing `void`.
  @js.JS('setCustomUserClaims')
  external js.JSPromise jsSetCustomUserClaims(
    String uid,
    js.JSAny? customUserClaims,
  );

  /// Updates an existing user.
  ///
  /// Returns a js.JSPromise containing updated [UserRecord].
  @js.JS('updateUser')
  external js.JSPromise<UserRecord> jsUpdateUser(
    String uid,
    UpdateUserRequest properties,
  );

  /// Verifies a Firebase ID token (JWT).
  ///
  /// If the token is valid, the returned js.JSPromise is fulfilled with an instance of
  /// [JSDecodedIdToken]; otherwise, the js.JSPromise is rejected. An optional flag can
  /// be passed to additionally check whether the ID token was revoked.
  @js.JS('jsVerifyIdToken')
  external js.JSPromise<JSDecodedIdToken> jsVerifyIdToken(
    String idToken, [
    bool? checkRevoked,
  ]);
}

extension type CreateUserRequest._(js.JSObject _) implements js.JSObject {
  external factory CreateUserRequest({
    bool? disabled,
    String? displayName,
    String? email,
    bool? emailVerified,
    String? password,
    String? phoneNumber,
    String? photoURL,
    String? uid,
  });
}

extension CreateUserRequestExt on CreateUserRequest {
  external bool get disabled;

  external String get displayName;

  external String get email;

  external bool get emailVerified;

  external String get password;

  external String get phoneNumber;

  external String get photoURL;

  external String get uid;
}

extension type UpdateUserRequest._(js.JSObject _) implements js.JSObject {
  external factory UpdateUserRequest({
    bool? disabled,
    String? displayName,
    String? email,
    bool? emailVerified,
    String? password,
    String? phoneNumber,
    String? photoURL,
  });
}

extension UpdateUserRequestExt on AuthModule {
  external bool get disabled;

  external String get displayName;

  external String get email;

  external bool get emailVerified;

  external String get password;

  external String get phoneNumber;

  external String get photoURL;
}

/// Interface representing a user.
///
/// [uid, email, emailVerified, displayName, photoURL, phoneNumber, disabled,
/// metadata, providerData, passwordHash, passwordSalt, tokensValidAfterTime, tenantId]
extension type UserRecord._(js.JSObject _) implements js.JSObject {}

extension UserRecordExt on UserRecord {
  /// The user's custom claims object if available, typically used to define user
  /// roles and propagated to an authenticated user's ID token.
  ///
  /// This is set via [AuthModule.setCustomUserClaims].
  external js.JSObject? get customClaims;

  /// Whether or not the user is disabled: true for disabled; false for enabled.
  external bool get disabled;

  /// The user's display name.
  external String? get displayName;

  /// The user's primary email, if set.
  external String? get email;

  /// Whether or not the user's primary email is verified.
  external bool get emailVerified;

  /// Additional metadata about the user.
  external UserMetadata get metadata;

  /// The user’s hashed password (base64-encoded), only if Firebase Auth hashing
  /// algorithm (SCRYPT) is used.
  ///
  /// If a different hashing algorithm had been used when uploading this user,
  /// typical when migrating from another Auth system, this will be an empty
  /// string. If no password is set, this will be`null`.
  ///
  /// This is only available when the user is obtained from [AuthModule.listUsers].
  external String get passwordHash;

  /// The user’s password salt (base64-encoded), only if Firebase Auth hashing
  /// algorithm (SCRYPT) is used.
  ///
  /// If a different hashing algorithm had been used to upload this user, typical
  /// when migrating from another Auth system, this will be an empty string.
  /// If no password is set, this will be `null`.
  ///
  /// This is only available when the user is obtained from [AuthModule.listUsers].
  external String get passwordSalt;

  /// The user's primary phone number or `null`.
  external String get phoneNumber;

  /// The user's photo URL or `null`.
  external String get photoURL;

  /// An array of providers (for example, Google, Facebook) linked to the user.
  List<UserInfo> get providerData => _providerData.toDart;

  @js.JS('providerData')
  external js.JSArray<UserInfo> get _providerData;

  /// The date the user's tokens are valid after, formatted as a UTC string.
  ///
  /// This is updated every time the user's refresh token are revoked either from
  /// the [AuthModule.revokeRefreshTokens] API or from the Firebase Auth backend on big
  /// account changes (password resets, password or email updates, etc).
  external String get tokensValidAfterTime;

  /// The user's uid.
  external String get uid;

  external js.JSObject toJSON();
}

extension type UserMetadata._(js.JSObject _) implements js.JSObject {}

extension UserMetadataExt on UserMetadata {
  /// The date the user was created, formatted as a UTC string.
  external String get creationTime;

  /// The date the user last signed in, formatted as a UTC string.
  external String get lastSignInTime;
}

/// Interface representing a user's info from a third-party identity provider
/// such as Google or Facebook.
extension type UserInfo._(js.JSObject _) implements js.JSObject {}

extension UserInfoExt on UserInfo {
  /// The display name for the linked provider.
  external String get displayName;

  /// The email for the linked provider.
  external String get email;

  /// The phone number for the linked provider.
  external String get phoneNumber;

  /// The photo URL for the linked provider.
  external String get photoURL;

  /// The linked provider ID (for example, "google.com" for the Google provider).
  external String get providerId;

  /// The user identifier for the linked provider.
  external String get uid;

  external js.JSObject toJSON();
}

/// Interface representing a resulting object returned from a [AuthModule.listUsers]
/// operation containing the list of users for the current batch and the next
/// page token if available.
extension type ListUsersResult._(js.JSObject _) implements js.JSObject {}

extension ListUsersResultExt on ListUsersResult {
  external String get pageToken;

  @js.JS('users')
  external js.JSArray<UserRecord> get _users;

  /// User list
  List<UserRecord> get users => _users.toDart;
}

/// Interface representing a decoded Firebase ID token, returned from the
/// [AuthModule.verifyIdToken] method.
extension type JSDecodedIdToken._(js.JSObject _) implements js.JSObject {}

extension JSDecodedIdTokenExt on JSDecodedIdToken {
  /// The audience for which this token is intended.
  ///
  /// This value is a string equal to your Firebase project ID, the unique
  /// identifier for your Firebase project, which can be found in your project's
  /// settings.
  external String get aud;

  /// Time, in seconds since the Unix epoch, when the end-user authentication
  /// occurred.
  ///
  /// This value is not when this particular ID token was created, but when the
  /// user initially logged in to this session. In a single session, the Firebase
  /// SDKs will refresh a user's ID tokens every hour. Each ID token will have a
  /// different [iat] value, but the same auth_time value.
  // ignore: non_constant_identifier_names
  external num get auth_time;

  /// The ID token's expiration time, in seconds since the Unix epoch.
  ///
  /// That is, the time at which this ID token expires and should no longer be
  /// considered valid.
  ///
  /// The Firebase SDKs transparently refresh ID tokens every hour, issuing a new
  /// ID token with up to a one hour expiration.
  external num get exp;

  /// Information about the sign in event, including which sign in provider was
  /// used and provider-specific identity details.
  ///
  /// This data is provided by the Firebase Authentication service and is a
  /// reserved claim in the ID token.
  external JSFirebaseSignInInfo get firebase;

  /// The ID token's issued-at time, in seconds since the Unix epoch.
  ///
  /// That is, the time at which this ID token was issued and should start to
  /// be considered valid.
  ///
  /// The Firebase SDKs transparently refresh ID tokens every hour, issuing a new
  /// ID token with a new issued-at time. If you want to get the time at which
  /// the user session corresponding to the ID token initially occurred, see the
  /// [auth_time] property.
  external num get iat;

  /// The issuer identifier for the issuer of the response.
  ///
  /// This value is a URL with the format
  /// `https://securetoken.google.com/<PROJECT_ID>`, where `<PROJECT_ID>` is the
  /// same project ID specified in the [aud] property.
  external String get iss;

  /// The uid corresponding to the user who the ID token belonged to.
  ///
  /// As a convenience, this value is copied over to the [uid] property.
  external String get sub;

  /// The uid corresponding to the user who the ID token belonged to.
  ///
  /// This value is not actually in the JWT token claims itself. It is added as a
  /// convenience, and is set as the value of the [sub] property.
  external String get uid;
}

extension type JSFirebaseSignInInfo._(js.JSObject _) implements js.JSObject {}

extension FirebaseSignInInfoExt on JSFirebaseSignInInfo {
  /// Provider-specific identity details corresponding to the provider used to
  /// sign in the user.
  external js.JSObject? get identities;

  /// The ID of the provider used to sign in the user. One of "anonymous",
  /// "password", "facebook.com", "github.com", "google.com", "twitter.com",
  /// or "custom".
  // ignore: non_constant_identifier_names
  external String get sign_in_provider;
}

extension AuthExt2 on Auth {
  /// Creates a new Firebase custom token (JWT) that can be sent back to a client
  /// device to use to sign in with the client SDKs' signInWithCustomToken()
  /// methods.
  ///
  /// Returns a [Future] containing a custom token string for the provided [uid]
  /// and payload.
  Future<String> createCustomToken(
    String uid, [
    Map<String, Object?>? developerClaims,
  ]) async => (await jsCreateCustomToken(
    uid,
    (developerClaims ?? <String, Object?>{}).jsify() as js.JSObject,
  ).toDart).toDart;

  /// Creates a new user.
  Future<UserRecord> createUser(CreateUserRequest properties) =>
      jsCreateUser(properties).toDart;

  /// Deletes an existing user.
  Future<void> deleteUser(String uid) => jsDeleteUser(uid).toDart;

  /// Gets the user data for the user corresponding to a given [uid].
  Future<UserRecord> getUser(String uid) => jsGetUser(uid).toDart;

  /// Gets the user data for the user corresponding to a given [email].
  Future<UserRecord> getUserByEmail(String email) =>
      jsGetUserByEmail(email).toDart;

  /// Gets the user data for the user corresponding to a given [phoneNumber].
  Future<UserRecord> getUserByPhoneNumber(String phoneNumber) =>
      jsGetUserByPhoneNumber(phoneNumber).toDart;

  /// Retrieves a list of users (single batch only) with a size of [maxResults]
  /// and starting from the offset as specified by [pageToken].
  ///
  /// This is used to retrieve all the users of a specified project in batches.
  Future<ListUsersResult> listUsers([int? maxResults, String? pageToken]) {
    if (pageToken != null && maxResults != null) {
      return jsListUsers(maxResults, pageToken).toDart;
    } else if (maxResults != null) {
      return jsListUsers(maxResults).toDart;
    } else {
      return jsListUsers().toDart;
    }
  }

  /// Revokes all refresh tokens for an existing user.
  ///
  /// This API will update the user's [UserRecord.tokensValidAfterTime] to the
  /// current UTC. It is important that the server on which this is called has
  /// its clock set correctly and synchronized.
  ///
  /// While this will revoke all sessions for a specified user and disable any
  /// new ID tokens for existing sessions from getting minted, existing ID tokens
  /// may remain active until their natural expiration (one hour). To verify that
  /// ID tokens are revoked, use [AuthModule.verifyIdToken] where `checkRevoked` is set to
  /// `true`.
  Future<void> revokeRefreshTokens(String uid) =>
      jsRevokeRefreshTokens(uid).toDart;

  /// Sets additional developer claims on an existing user identified by the
  /// provided [uid], typically used to define user roles and levels of access.
  ///
  /// These claims should propagate to all devices where the user is already
  /// signed in (after token expiration or when token refresh is forced) and the
  /// next time the user signs in. If a reserved OIDC claim name is used
  /// (sub, iat, iss, etc), an error is thrown. They will be set on the
  /// authenticated user's ID token JWT.
  ///
  /// [customUserClaims] can be `null` in which case existing custom
  /// claims are deleted. Passing a custom claims payload larger than 1000 bytes
  /// will throw an error. Custom claims are added to the user's ID token which
  /// is transmitted on every authenticated request. For profile non-access
  /// related user attributes, use database or other separate storage systems.
  Future<void> setCustomUserClaims(
    String uid,
    Map<String, Object?> customUserClaims,
  ) => jsSetCustomUserClaims(uid, customUserClaims.jsify()).toDart;

  /// Updates an existing user.
  Future<UserRecord> updateUser(String uid, UpdateUserRequest properties) =>
      jsUpdateUser(uid, properties).toDart;

  /// Verifies a Firebase ID token (JWT).
  ///
  /// If the token is valid, the returned [Future] is completed with an instance
  /// of [JSDecodedIdToken]; otherwise, the future is completed with an error.
  /// An optional flag can be passed to additionally check whether the ID token
  /// was revoked.
  Future<JSDecodedIdToken> verifyIdToken(String idToken, [bool? checkRevoked]) {
    if (checkRevoked != null) {
      return jsVerifyIdToken(idToken, checkRevoked).toDart;
    } else {
      return jsVerifyIdToken(idToken).toDart;
    }
  }
}
