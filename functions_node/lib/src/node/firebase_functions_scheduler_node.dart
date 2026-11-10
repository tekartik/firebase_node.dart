import 'dart:js_interop';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_scheduler_node_js_interop.dart'
    as node;

import 'firebase_functions_node.dart';
import 'global_options_node.dart';

class SchedulerFunctionsNode
    with SchedulerFunctionsDefaultMixin
    implements SchedulerFunctions {
  final FirebaseFunctionsNode functions;
  final node.JSSchedulerFunctions nativeInstance;

  SchedulerFunctionsNode(this.functions, this.nativeInstance);

  @override
  ScheduleFunction onSchedule(
    ScheduleOptions scheduleOptions,
    ScheduleHandler handler,
  ) {
    FutureOr<void> handleRequest(node.JSScheduledEvent data) {
      var scheduleEvent = ScheduleEventNode(data);
      return handler(scheduleEvent);
    }

    return SchedulerFunctionNode(
      functions,
      nativeInstance.onSchedule(
        options: toNodeScheduleOptions(scheduleOptions),
        handler: handleRequest,
      ),
    );
  }
}

class SchedulerFunctionNode extends FirebaseFunctionNode
    implements ScheduleFunction {
  @override
  final node.JSScheduleFunction nativeInstance;

  SchedulerFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

/// The native options of [options], only its non null values set (see
/// [nodeOptionsSetIfNotNull]): a null `timeoutSeconds` fails
/// firebase-functions 7.3+, a null `region` or `memory` overrides the global
/// options.
node.JSScheduleOptions toNodeScheduleOptions(ScheduleOptions options) {
  var nativeOptions = node.JSScheduleOptions(schedule: options.schedule);
  nodeOptionsSetIfNotNull(nativeOptions, 'region', options.region?.toJS);
  nodeOptionsSetIfNotNull(nativeOptions, 'timeZone', options.timeZone?.toJS);
  // memory and timeoutSeconds: set by globalOptionsApplyToNode.
  return globalOptionsApplyToNode(nativeOptions, options);
}

class ScheduleEventNode
    with SchedulerEventDefaultMixin
    implements ScheduleEvent {
  final node.JSScheduledEvent nativeInstance;

  ScheduleEventNode(this.nativeInstance);

  @override
  String? get jobName => nativeInstance.jobName;

  @override
  String? get scheduleTime => nativeInstance.scheduleTime;
}
