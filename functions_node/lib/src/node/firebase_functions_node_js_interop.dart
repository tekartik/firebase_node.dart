// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase_functions_node/src/import_common.dart';

import 'import_node.dart';

/// The Firebase Auth service interface.
final firebaseFunctionsModule =
    require<JSFirebaseFonctionsModule>('firebase-functions/v2');
final firebaseFunctions = firebaseFunctionsModule;
extension type JSFirebaseFonctionsModule._(js.JSObject _)
    implements js.JSObject {}

extension JSFirebaseFonctionsExt on JSFirebaseFonctionsModule {
  void operator []=(String key, JSFirebaseFunction function) {
    exports.setProperty(key.toJS, function);
  }

  external JSHttpsFunctions get https;
}

extension type JSHttpsFunctions._(js.JSObject _) implements js.JSObject {}

extension JSHttpsFunctionsExt on JSHttpsFunctions {
  // Handles HTTPS requests.
  //
  // Signature:
  // export declare function onRequest(opts: HttpsOptions, handler: (request: Request, response: express.Response) => void | Promise<void>): HttpsFunction;

  @js.JS('onRequest')
  external JSHttpsFunction _onRequest(
      JSHttpsOptions options, _JSHttpsHandler handler);

  @js.JS('onRequest')
  external JSHttpsFunction _onRequestNoOptions(_JSHttpsHandler handler);

  JSHttpsFunction onRequest(
      {JSHttpsOptions? options, required HttpsHandler handler}) {
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
}

// An express request with the wire format representation of the request body.
//
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

  JSHttpsResponse setHeader(String field, String value) =>
      _setHeader(field, value.toJS);
  JSHttpsResponse setHeaderList(String field, List<String> values) =>
      _setHeader(field, values.map((e) => e.toJS).toList().toJS);
}

extension JSHttpsResponseExt on JSHttpsResponse {}

typedef JSHttpsFunction = js.JSFunction;
typedef _JSHttpsHandler = js.JSFunction;

typedef HttpsHandler = FutureOr<void> Function(
    JSHttpsRequest request, JSHttpsResponse response);

@js.JS('exports')
external JSExports get exports;

extension type JSExports._(js.JSObject _) implements js.JSObject {}

extension JSExportsExt on JSExports {}

typedef JSFirebaseFunction = js.JSFunction;

extension type JSHttpsOptions._(js.JSObject _) implements js.JSObject {
  /// Options
  external factory JSHttpsOptions(
      {String? region,
      String? memory,
      int? concurrency,
      js.JSAny? cors,
      int? timeoutSeconds});
}

extension JSHttpsOptionsExt on JSHttpsOptions {
  /// String or array string
  external String? get region;

  /// Amount of memory to allocate to a function.
  /// "128MiB" | "256MiB" | "512MiB" | "1GiB" | "2GiB" | "4GiB" | "8GiB" | "16GiB" | "32GiB";
  /// external Object? get region;
  external String? get memory;

  /// Number of requests a function can serve at once.
  external int? get concurrency;

  /// string | boolean | RegExp | Array<string | RegExp>
  ///
  /// If true, allows CORS on requests to this function. If this is a string or
  /// RegExp, allows requests from domains that match the provided value. If
  /// this is an Array, allows requests from domains matching at least one entry
  /// of the array. Defaults to true for https.CallableFunction and false
  /// otherwise.
  external js.JSAny? get cors;

  /// Timeout for the function in sections, possible values are 0 to 540. HTTPS functions can specify a higher timeout.
  external int? get timeoutSeconds;
}
