import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;

import 'firebase_functions_node.dart';

class PubsubFunctionsNode implements common.PubsubFunctions {
  final FirebaseFunctionsNode functions;
  PubsubFunctionsNode(this.functions);

  @override
  common.ScheduleBuilder schedule(String expression) {
    return ScheduleBuilderNode(
        functions.implFunctions.pubsub.schedule(expression));
  }
}

class PubsubFunctionNode extends FirebaseFunctionNode
    implements common.PubsubFunction {
  // ignore: unused_field
  final _implCloudFonction;

  PubsubFunctionNode(this._implCloudFonction);

  @override
  dynamic get value => _implCloudFonction;

  @override
  String toString() => _implCloudFonction.toString();
}

class ScheduleBuilderNode implements common.ScheduleBuilder {
  final impl.ScheduleBuilder _implScheduleBuilder;

  ScheduleBuilderNode(this._implScheduleBuilder);

  @override
  common.PubsubFunction onRun(common.ScheduleEventHandler handler) {
    FutureOr<void> _handle(dynamic data, impl.EventContext context) {
      return handler(ScheduleContextNode(context));
    }

    return PubsubFunctionNode(_implScheduleBuilder.onRun(_handle));
  }
}

class ScheduleContextNode implements common.ScheduleContext {
  // ignore: unused_field
  final impl.EventContext _implEventContext;

  ScheduleContextNode(this._implEventContext);
}
