// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

// ignore: implementation_imports
import 'package:tekartik_firebase_auth_node/src/node/auth_node_js_interop.dart'
    as js;
import 'package:tekartik_firebase_functions_node/src/import_common.dart';

import 'firebase_functions_node_js_interop.dart';

extension type JSHttpsFunctions._(js.JSObject _) implements js.JSObject {}

extension JSHttpsFunctionsExt on JSHttpsFunctions {
  // Handles HTTPS requests.
  //
  // Signature:
  // export declare function onRequest(opts: HttpsOptions, handler: (request: Request, response: express.Response) => void | Promise<void>): HttpsFunction;

  @js.JS('onRequest')
  external JSHttpsFunction _onRequest(
    JSHttpsOptions options,
    _JSHttpsHandler handler,
  );

  @js.JS('onRequest')
  external JSHttpsFunction _onRequestNoOptions(_JSHttpsHandler handler);

  @js.JS('onCall')
  external JSCallableFunction _onCall(
    JSCallableOptions options,
    _JSCallableHandler handler,
  );

  @js.JS('onCall')
  external JSHttpsFunction _onCallNoOptions(_JSCallableHandler handler);

  JSHttpsFunction onRequest({
    JSHttpsOptions? options,
    required HttpsHandler handler,
  }) {
    js.JSAny? jsHandler(JSHttpsRequest request, JSHttpsResponse response) {
      var result = handler(request, response);
      if (result is Future) {
        return result.toJS;
      } else {
        return null;
      }
    }

    if (options == null) {
      //devPrint('Setting handler no options');
      return _onRequestNoOptions(jsHandler.toJS);
    } else {
      // devPrint('Setting handler');
      return _onRequest(options, jsHandler.toJS);
    }
  }

  JSCallableFunction onCall({
    JSCallableOptions? options,
    required CallableHandler handler,
  }) {
    js.JSAny? jsHandler(JSCallableRequest request) {
      var result = handler(request);
      if (result is Future) {
        return result.then((value) => (value as Object?)?.jsify()).toJS;
      } else {
        return result.jsify()!;
      }
    }

    if (options == null) {
      return _onCallNoOptions(jsHandler.toJS);
    } else {
      return _onCall(options, jsHandler.toJS);
    }
  }

  @js.JS('HttpsError')
  external JSHttpsErrorProto get httpsErrorProto;
}

/// An express request with the wire format representation of the request body.
extension type JSHttpsRequest._(js.JSObject _) implements js.JSObject {}

extension JSHttpsRequestExt on JSHttpsRequest {
  /// From node IncomingMessage
  /// Request URL string. This contains only the URL that is present in the actual HTTP request.
  /// For example: '/status?name=ryan'
  external String get url;

  /// Firebase function extension
  ///
  /// Buffer	The wire format representation of the request body.
  /// Buffer is not only and extends Uint8Array
  external js.JSUint8Array? get rawBody;

  /// The request method as a string. Read only. Examples: 'GET', 'DELETE'.
  external String get method;

  /// The request/response headers object.
  ///
  /// Key-value pairs of header names and values. Header names are lower-cased.
  ///
  /// Prints something like:
  ///
  ///  { 'user-agent': 'curl/7.22.0',
  ///   host: '127.0.0.1:8000',
  ///   accept: '*/*' }
  /// console.log(request.headers); COPY
  /// Duplicates in raw headers are handled in the following ways, depending on the header name:
  ///
  /// Duplicates of age, authorization, content-length, content-type, etag, expires, from, host, if-modified-since, if-unmodified-since, last-modified, location, max-forwards, proxy-authorization, referer, retry-after, server, or user-agent are discarded. To allow duplicate values of the headers listed above to be joined, use the option joinDuplicateHeaders in http.request() and http.createServer(). See RFC 9110 Section 5.3 for more information.
  /// set-cookie is always an array. Duplicates are added to the array.
  /// For duplicate cookie headers, the values are joined together with ; .
  /// For all other headers, the values are joined together with ,
  external js.JSAny? get headers;
}

extension type JSHttpsResponse._(js.JSObject _) implements js.JSObject {
  /// https://expressjs.com/en/4x/api.html#res.send
  /// Sends the HTTP response.
  /// The body parameter can be a Buffer object, a String, an object, Boolean, or an Array. For example:
  external void send([js.JSAny? body]);

  /// Ends the response process. This method actually comes from Node core,
  /// specifically the response.end() method of http.ServerResponse.
  external void end();

  /// Sets the HTTP status for the response.
  /// It is a chainable alias of Node’s response.statusCode.
  external JSHttpsResponse status(int statusCode);

  /// Appends the specified value to the HTTP response header field.
  /// If the header is not already set, it creates the header with the
  /// specified value. The value parameter can be a string or an array.
  ///
  /// Note: calling res.set() after res.append() will reset the previously-set header value.
  ///
  /// res.append('Link', ['<http://localhost/>', '<http://localhost:3000/>'])
  /// res.append('Set-Cookie', 'foo=bar; Path=/; HttpOnly')
  /// res.append('Warning', '199 Miscellaneous warning')
  @js.JS('append')
  external JSHttpsResponse _setHeader(String field, js.JSAny value);

  /// res.redirect([status,] path)
  /// Redirects to the URL derived from the specified path, with specified status, a positive integer that corresponds to an HTTP status code . If not specified, status defaults to “302 “Found”.
  @js.JS('redirect')
  external void _redirect(String path);

  @js.JS('redirect')
  external void _statusRedirect(int status, String path);

  void redirect(String path, {int? status}) {
    if (status == null) {
      _redirect(path);
    } else {
      _statusRedirect(status, path);
    }
  }

  JSHttpsResponse setHeader(String field, String value) =>
      _setHeader(field, value.toJS);

  JSHttpsResponse setHeaderList(String field, List<String> values) =>
      _setHeader(field, values.map((e) => e.toJS).toList().toJS);
}

extension JSHttpsResponseExt on JSHttpsResponse {}

typedef JSHttpsFunction = js.JSFunction;
typedef JSCallableFunction = js.JSFunction;
typedef _JSHttpsHandler = js.JSFunction;
typedef _JSCallableHandler = js.JSFunction;

typedef HttpsHandler =
    FutureOr<void> Function(JSHttpsRequest request, JSHttpsResponse response);
typedef CallableHandler = FutureOr<Object?> Function(JSCallableRequest request);
typedef JSFirebaseFunction = js.JSFunction;

/// Options that can be set on an onRequest HTTPS function.
///
/// export interface HttpsOptions extends `Omit<GlobalOptions, "region">`
extension type JSHttpsOptions._(js.JSObject _) implements JSGlobalOptions {
  /// Options
  external factory JSHttpsOptions({
    String? region,
    String? memory,
    int? concurrency,
    js.JSAny? cors,
    int? timeoutSeconds,
  });
}

/// Options that can be set on an onRequest HTTPS function.
///
/// export interface HttpsOptions extends `Omit<GlobalOptions, "region">`
extension type JSCallableOptions._(js.JSObject _) implements JSHttpsOptions {
  /// Options
  external factory JSCallableOptions({
    String? region,
    String? memory,
    int? concurrency,
    js.JSAny? cors,
    int? timeoutSeconds,

    /// Determines whether Firebase App Check token is consumed on request. Defaults to false.
    bool? consumeAppCheckToken,

    /// Determines whether Firebase AppCheck is enforced. When true, requests with invalid tokens autorespond with a 401 (Unauthorized) error. When false, requests with invalid tokens set event.app to undefiend.
    bool? enforceAppCheck,
  });
}

/// Options that can be set on an onRequest HTTPS function.
///
/// export interface HttpsOptions extends `Omit<GlobalOptions, "region">`
extension type JSHttpsError._(js.JSObject _) implements js.JSObject {
  factory JSHttpsError(String code, String message, [js.JSAny? details]) {
    return firebaseFunctionsModule.https.httpsErrorProto.newHttpsError(
      code,
      message,
      details,
    );
  }
}

extension JSHttpsErrorExt on JSHttpsError {
  /// A standard error code that will be returned to the client. This also determines the HTTP status code of the response, as defined in code.proto.
  external String code;

  /// Message
  external String message;

  /// Extra data to be converted to JSON and included in the error response.
  /// This data must be JSON-serializable.
  external js.JSAny? get details;
}

extension type JSHttpsErrorProto._(js.JSObject _) implements js.JSObject {}

extension JSHttpsErrorProtoExt on JSHttpsErrorProto {
  /// Options
  JSHttpsError newHttpsError(String code, String message, [js.JSAny? details]) {
    if (details == null) {
      return (this as js.JSFunction).callAsConstructor(code.toJS, message.toJS);
    } else {
      return (this as js.JSFunction).callAsConstructor(
        code.toJS,
        message.toJS,
        details,
      );
    }
  }

  /// Extra data to be converted to JSON and included in the error response.
  external js.JSAny? details;
}

extension JSHttpsOptionsExt on JSHttpsOptions {
  /// string | boolean | RegExp | `Array<string | RegExp>`
  ///
  /// If true, allows CORS on requests to this function. If this is a string or
  /// RegExp, allows requests from domains that match the provided value. If
  /// this is an Array, allows requests from domains matching at least one entry
  /// of the array. Defaults to true for https.CallableFunction and false
  /// otherwise.
  external js.JSAny? get cors;
}

/// Metadata about the authorization used to invoke a function.
extension type JSAuthData._(js.JSObject _) implements js.JSObject {}

extension JSAuthDataExt on JSAuthData {
  external js.JSDecodedIdToken get token;

  external String get uid;
}

/// An express request with the wire format representation of the request body.
extension type JSCallableRequest._(js.JSObject _) implements js.JSObject {}

extension JSCallableRequestExt on JSCallableRequest {
  /// The result of decoding and verifying a Firebase Auth ID token.
  external JSAuthData? get auth;

  /// The parameters used by a client when calling this function.
  external js.JSAny? get data;
}
