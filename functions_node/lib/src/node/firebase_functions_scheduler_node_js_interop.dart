// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop' as js;

import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart';

extension type JSSchedulerFunctions._(js.JSObject _) implements js.JSObject {}

extension JSSchedulerFunctionsExt on JSSchedulerFunctions {
  // Handles HTTPS requests.
  //
  // Signature:
  /// onSchedule(options, handler)	Handler for scheduled functions.
  /// Triggered whenever the associated scheduler job sends a http request.

  @js.JS('onSchedule')
  external JSScheduleFunction _onSchedule(
      JSScheduleOptions options, _JSScheduleHandler handler);

  JSScheduleFunction onSchedule(
      {required JSScheduleOptions options, required ScheduleHandler handler}) {
    js.JSAny? jsHandler(JSScheduledEvent data) {
      var result = handler(data);
      if (result is Future) {
        return result.toJS;
      } else {
        return null;
      }
    }

    return _onSchedule(options, jsHandler.toJS);
  }
}

typedef JSScheduleFunction = js.JSFunction;
typedef _JSScheduleHandler = js.JSFunction;

/// Interface representing a ScheduleEvent that is passed to the function handler.
//
// Signature:
//
//
// export interface ScheduledEvent
// Properties
// Property	Type	Description

extension type JSScheduledEvent._(js.JSObject _) implements js.JSObject {}

extension JSScheduledEventExt on JSScheduledEvent {
  /// jobName	string
  /// The Cloud Scheduler job name. Populated via the X-CloudScheduler-JobName header.
  /// If invoked manually, this field is undefined.
  external String? get jobName;

  /// scheduleTime	string
  /// For Cloud Scheduler jobs specified in the unix-cron format,
  /// this is the job schedule time in RFC3339 UTC "Zulu" format. Populated via the X-CloudScheduler-ScheduleTime header.
  /// If the schedule is manually triggered, this field will be the function execution time.
  external String? get scheduleTime;
}

typedef ScheduleHandler = FutureOr<void> Function(JSScheduledEvent event);

extension type JSScheduleOptions._(js.JSObject _) implements JSGlobalOptions {
  /// Options
  external factory JSScheduleOptions(
      {String? region,
      String? memory,
      int? concurrency,
      required String schedule,
      String? timeZone,
      int? timeoutSeconds});
}

extension JSHttpsOptionsExt on JSScheduleOptions {
  /// The schedule, in Unix Crontab or AppEngine syntax.
  ///
  /// schedule: string
  external String? get schedule;

  /// The timezone that the schedule executes in.
  ///
  /// timeZone?: timezone | Expression<string> | ResetValue
  external String? get timeZone;
}
