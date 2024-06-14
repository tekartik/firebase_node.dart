import 'dart:js_interop';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_http/firebase_functions_http.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node_js_interop.dart'
    as node;
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart'
    as node;
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_scheduler_node_js_interop.dart'
    as node;

import 'express_http_request_node.dart';

final firebaseFunctionsNode = FirebaseFunctionsNode();

class FirebaseFunctionsNode extends FirebaseFunctionsHttp {
  final nativeInstance = node.firebaseFunctionsModule;

  @override
  void operator []=(String key, FirebaseFunction function) {
    nativeInstance[key] = (function as FirebaseFunctionNode).nativeInstance;
  }

  @override
  HttpsFunctions get https => HttpsFunctionsNode(this, nativeInstance.https);

  @override
  SchedulerFunctions get scheduler =>
      SchedulerFunctionsNode(this, nativeInstance.scheduler);
}

class HttpsFunctionsNode with HttpsFunctionsMixin implements HttpsFunctions {
  final FirebaseFunctionsNode functions;
  final node.JSHttpsFunctions nativeInstance;

  HttpsFunctionsNode(this.functions, this.nativeInstance);

  @override
  HttpsFunction onRequest(RequestHandler handler) {
    return onRequestV2(HttpsOptions(), handler);
  }

  @override
  HttpsFunction onRequestV2(HttpsOptions httpsOptions, RequestHandler handler) {
    void handleRequest(
        node.JSHttpsRequest request, node.JSHttpsResponse response) {
      var expressRequest = ExpressHttpRequestNode(request, response);
      handler(expressRequest);
    }

    return HttpsFunctionNode(
        functions,
        nativeInstance.onRequest(
            options: toNodeHttpsOptions(httpsOptions), handler: handleRequest));

    //throw UnimplementedError('onRequestV2');
  }
}

abstract class FirebaseFunctionNode implements FirebaseFunction {
  final FirebaseFunctionsNode firebaseFunctionsNode;

  FirebaseFunctionNode(this.firebaseFunctionsNode);

  node.JSFirebaseFunction get nativeInstance;
}

class HttpsFunctionNode extends FirebaseFunctionNode implements HttpsFunction {
  @override
  final node.JSHttpsFunction nativeInstance;

  HttpsFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

node.JSHttpsOptions toNodeHttpsOptions(HttpsOptions httpsOptions) {
  return node.JSHttpsOptions(
      region: httpsOptions.region, cors: httpsOptions.cors?.toJS);
}

class SchedulerFunctionNode extends FirebaseFunctionNode
    implements ScheduleFunction {
  @override
  final node.JSScheduleFunction nativeInstance;

  SchedulerFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

node.JSScheduleOptions toNodeScheduleOptions(ScheduleOptions options) {
  return node.JSScheduleOptions(
      region: options.region,
      schedule: options.schedule,
      timeZone: options.timeZone,
      memory: options.memory,
      timeoutSeconds: options.timeoutSeconds);
}

class SchedulerFunctionsNode
    with SchedulerFunctionsDefaultMixin
    implements SchedulerFunctions {
  final FirebaseFunctionsNode functions;
  final node.JSSchedulerFunctions nativeInstance;

  SchedulerFunctionsNode(this.functions, this.nativeInstance);

  @override
  ScheduleFunction onSchedule(
      ScheduleOptions scheduleOptions, ScheduleHandler handler) {
    FutureOr<void> handleRequest(node.JSScheduledEvent data) {
      var scheduleEvent = ScheduleEventNode(data);
      return handler(scheduleEvent);
    }

    return SchedulerFunctionNode(
        functions,
        nativeInstance.onSchedule(
            options: toNodeScheduleOptions(scheduleOptions),
            handler: handleRequest));
  }
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
