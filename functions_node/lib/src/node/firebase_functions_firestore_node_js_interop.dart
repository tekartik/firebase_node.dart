// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop' as js;

// ignore: implementation_imports
import 'package:tekartik_firebase_firestore_node/src/node/firestore_node_js_interop.dart'
    as firestore;
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart';

extension type JSFirestoreFunctions._(js.JSObject _) implements js.JSObject {}

extension JSFirestoreFunctionsExt on JSFirestoreFunctions {
  /// Event handler which triggers when a document is created, updated, or deleted in Firestore.
  ///
  /// export declare function `onDocumentWritten<Document extends string>(document: Document, handler: (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, ParamsOf<Document>>) => any | Promise<any>): CloudFunction<FirestoreEvent<Change<DocumentSnapshot> | undefined, ParamsOf<Document>.`

  @js.JS('onDocumentWritten')
  external JSFirestoreFunction _onDocumentWritten(
      JSDocumentOptions options, _JSDocumentWrittenHandler handler);

  JSFirestoreFunction onDocumentWritten(
      {required JSDocumentOptions options,
      required DocumentWrittenHandler handler}) {
    js.JSAny? jsHandler(
        JSFirestoreEvent<JSChange<firestore.DocumentSnapshot>> data) {
      return handler(data).toJSOrNull;
    }

    return _onDocumentWritten(options, jsHandler.toJS);
  }
}

typedef DocumentWrittenHandler = FutureOr<void> Function(
    JSFirestoreEvent<JSChange<firestore.DocumentSnapshot>> event);

typedef JSFirestoreFunction = js.JSFunction;
typedef _JSDocumentWrittenHandler = js.JSFunction;

/// A CloudEvent that contains a DocumentSnapshot or a Change
extension type JSFirestoreEvent<T extends js.JSAny?>._(js.JSObject _)
    implements JSCloudEvent<T> {}

extension JSFirestoreEventExt<T extends js.JSAny?> on JSFirestoreEvent<T> {
  /// The document path
  external String get document;
}

/// A CloudEventBase is the base of a cross-platform format for encoding a serverless event. For more information, see https://github.com/cloudevents/spec.
extension type JSCloudEvent<T extends js.JSAny?>._(js.JSObject _)
    implements js.JSObject {}

extension JSCloudEventExt<T extends js.JSAny?> on JSCloudEvent<T> {
  /// Information about this specific event.
  external T get data;
}

/// EventHandlerOptions interface
///
/// export interface EventHandlerOptions extends `Omit<GlobalOptions, "enforceAppCheck">`
extension type JSEventHandlerOptions._(js.JSObject _)
    implements JSGlobalOptions {
  external factory JSEventHandlerOptions(
      {String? region, String? memory, int? concurrency, int? timeoutSeconds});
}

/// firestore.DocumentOptions interface
/// export interface `DocumentOptions<Document extends string = string>` extends EventHandlerOptions
extension type JSDocumentOptions._(js.JSObject _)
    implements JSEventHandlerOptions {
  /// Options
  external factory JSDocumentOptions(
      {String? region,
      String? memory,
      int? concurrency,
      int? timeoutSeconds,

      ///document	Document	The document path
      required String document});
}

/// Change class
/// The Cloud Functions interface for events that change state, such as Realtime Database or Cloud Firestore onWrite and onUpdate events.
/// export declare class `Change<T>`
extension type JSChange<T extends js.JSAny?>._(js.JSObject _)
    implements js.JSObject {}

extension JSChangeExt<T extends js.JSAny?> on JSChange<T> {
  /// The state after the event.
  external T get after;

  /// The state prior to the event.
  external T get before;
}
