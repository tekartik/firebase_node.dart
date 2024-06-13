// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'import_node.dart';

/// The Firebase Auth service interface.
final firebaseFunctionsModule =
    require<FirebaseFonctionsModule>('firebase-functions/v2');
final firebaseFunctions = firebaseFunctionsModule;
extension type FirebaseFonctionsModule._(js.JSObject _)
    implements js.JSObject {}

extension FirebaseFonctionsExt on FirebaseFonctionsModule {
  void operator []=(String key, FirebaseFunction function) {
    exports.setProperty(key.toJS, function);
  }

  external HttpsFunctions get https;
}

extension type HttpsFunctions._(js.JSObject _) implements js.JSObject {}

extension HttpsFunctionsExt on HttpsFunctions {
  // Handles HTTPS requests.
  //
  // Signature:
  // export declare function onRequest(opts: HttpsOptions, handler: (request: Request, response: express.Response) => void | Promise<void>): HttpsFunction;

  @js.JS('onRequest')
  external HttpsFunction _onRequest(
      HttpsOptions options, _HttpsHandler handler);

  @js.JS('onRequest')
  external HttpsFunction _onRequestNoOptions(_HttpsHandler handler);

  HttpsFunction onRequest(
      {HttpsOptions? options, required HttpsHandler handler}) {
    js.JSAny? jsHandler(HttpsRequest request, HttpsResponse response) {
      var result = handler(request, response);
      if (result is Future) {
        return result.toJS;
      } else {
        return null;
      }
    }

    if (options == null) {
      return _onRequestNoOptions(jsHandler.toJS);
    } else {
      return _onRequest(options, jsHandler.toJS);
    }
  }
}

// An express request with the wire format representation of the request body.
//
extension type HttpsRequest._(js.JSObject _) implements js.JSObject {}

extension HttpsRequestExt on HttpsRequest {
  external js.JSUint8Array get rawBody;
}

extension type HttpsResponse._(js.JSObject _) implements js.JSObject {}

extension HttpsResponseExt on HttpsResponse {}

typedef HttpsFunction = js.JSFunction;
typedef _HttpsHandler = js.JSFunction;

typedef HttpsHandler = FutureOr<void> Function(
    HttpsRequest request, HttpsResponse response);

@js.JS('exports')
external Exports get exports;

extension type Exports._(js.JSObject _) implements js.JSObject {}

extension ExportsExt on Exports {}

typedef FirebaseFunction = js.JSFunction;

extension type HttpsOptions._(js.JSObject _) implements js.JSObject {
  /// Options
  external factory HttpsOptions(
      {String? region,
      String? memory,
      int? concurrency,
      js.JSAny? cors,
      int? timeoutSeconds});
}

extension HttpsOptionsExt on HttpsOptions {
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
