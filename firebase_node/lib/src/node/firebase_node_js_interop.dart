// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library;

import 'dart:js_interop' as js;

import 'package:tekartik_core_node/require.dart' as node;
// admin =========================================================================

const defaultAppName = '[DEFAULT]';

/// Singleton instance of [FirebaseAdminModule] module.
final firebaseAdminModule =
    node.require<FirebaseAdminModule>('firebase-admin/app');

extension type FirebaseAdminModule._(js.JSObject _) implements js.JSObject {}

extension FirebaseAdminExt on FirebaseAdminModule {
  /// Creates and initializes a Firebase app instance.
  external App initializeApp([AppOptions? options, String? name]);

  /// The current SDK version.
  // ignore: non_constant_identifier_names
  external String get SDK_VERSION;

  /// A (read-only) array of all initialized apps.
  external js.JSArray<App> get apps;

  /// Retrieves a Firebase [App] instance.
  ///
  /// When called with no arguments, the default app is returned. When an app
  /// [name] is provided, the app corresponding to that name is returned.
  ///
  /// An exception is thrown if the app being retrieved has not yet been
  /// initialized.
  external App app([String? name]);

  /// Returns a [Credential] created from the Google Application Default
  /// Credentials (ADC) that grants admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  external Credential applicationDefault();

  /// cert(serviceAccountPathOrObject, httpAgent)
  /// Returns a credential created from the provided service account that grants admin access to Firebase services. This credential can be used in the call to initializeApp().
  /// export declare function cert(serviceAccountPathOrObject: string | ServiceAccount, httpAgent?: Agent): Credential;
  @js.JS('cert')
  external Credential serviceAccountCredential(ServiceAccount serviceAccount);

  /// export declare namespace credential
  external Credentials get credential;
}

// admin.credential ============================================================

extension type Credentials._(js.JSObject _) implements js.JSObject {}

extension CredentialsExt on Credentials {
  /// Returns a [Credential] created from the Google Application Default
  /// Credentials (ADC) that grants admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  external Credential applicationDefault();

  /// Returns [Credential] created from the provided service account that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  /// [credentials] must be a path to a service account key JSON file or an
  /// object representing a service account key.
  external Credential cert(String credentialsPath);

  /// Returns [Credential] created from the provided refresh token that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  external Credential refreshToken(String refreshTokenPath);
}

extension type ServiceAccount._(js.JSObject _) implements js.JSObject {
  external factory ServiceAccount(
      // ignore: non_constant_identifier_names
      {String? projectId,
      // ignore: non_constant_identifier_names
      String? clientEmail,
      // ignore: non_constant_identifier_names
      String? privateKey});
}

extension ServiceAccountExt on ServiceAccount {
  // ignore: non_constant_identifier_names
  external String get projectId;

  // ignore: non_constant_identifier_names
  external String get clientEmail;

  // ignore: non_constant_identifier_names
  external String get privateKey;
}

/// Interface which provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
extension type Credential._(js.JSObject _) implements js.JSObject {}

extension CredentialExt on Credential {
  /// Returns a Google OAuth2 [AccessToken] object used to authenticate with
  /// Firebase services.
  ///
  /// Returns node.Promise<AccessToken>.
  external js.JSPromise getAccessToken();
}

/// Google OAuth2 access token object used to authenticate with Firebase
/// services.
extension type AccessToken._(js.JSObject _) implements js.JSObject {}

extension AccessTokenExt on AccessToken {
  /// The actual Google OAuth2 access token.
  // ignore: non_constant_identifier_names
  external String get access_token;

  /// The number of seconds from when the token was issued that it expires.
  // ignore: non_constant_identifier_names
  external num get expires_in;
}

// admin.app ===================================================================

/// A Firebase app holds the initialization information for a collection of
/// services.
extension type App._(js.JSObject _) implements js.JSObject {}

extension AppExt on App {
  /// The name for this app.
  ///
  /// The default app's name is `[DEFAULT]`.
  external String get name;

  /// The (read-only) configuration options for this app. These are the original
  /// parameters given in [initializeApp].
  external AppOptions get options;

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  external js.JSPromise delete();
}

/// Available options to pass to [initializeApp].
extension type AppOptions._(js.JSObject _) implements js.JSObject {
  /// Creates new instance of [AppOptions].
  external factory AppOptions({
    Credential? credential,
    String? databaseURL,
    String? projectId,
    String? storageBucket,
  });
}

extension AppOptionsExt on AppOptions {
  /// A [Credential] object used to authenticate the Admin SDK.
  ///
  /// You can obtain a credential via one of the following methods:
  ///
  /// - [applicationDefaultCredential]
  /// - [cert]
  /// - [refreshToken]
  external Credential get credential;

  /// The URL of the Realtime Database from which to read and write data.
  external String? get databaseURL;

  /// The ID of the Google Cloud project associated with the App.
  external String? get projectId;

  /// The name of the default Cloud Storage bucket associated with the App.
  external String? get storageBucket;
}
