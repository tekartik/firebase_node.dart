// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'firebase_functions_https_node_js_interop.dart';
import 'firebase_functions_scheduler_node_js_interop.dart';
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

  external JSSchedulerFunctions get scheduler;
}

@js.JS('exports')
external JSExports get exports;

extension type JSExports._(js.JSObject _) implements js.JSObject {}

extension JSExportsExt on JSExports {}

/// GlobalOptions are options that can be set across an entire project.
/// These options are common to HTTPS and event handling functions.
extension type JSGlobalOptions._(js.JSObject _) implements js.JSObject {
  /// Options
  external factory JSGlobalOptions(
      {String? region, String? memory, int? concurrency, int? timeoutSeconds});
}

extension JSGlobalOptionsExt on JSGlobalOptions {
  /// String or array string
  external String? get region;

  /// Amount of memory to allocate to a function.
  /// "128MiB" | "256MiB" | "512MiB" | "1GiB" | "2GiB" | "4GiB" | "8GiB" | "16GiB" | "32GiB";
  /// external Object? get region;
  external String? get memory;

  /// Number of requests a function can serve at once.
  external int? get concurrency;

  /// Timeout for the function in sections, possible values are 0 to 540. HTTPS functions can specify a higher timeout.
  external int? get timeoutSeconds;
}
