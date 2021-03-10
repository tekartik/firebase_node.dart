import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:node_io/node_io.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;
import 'package:tekartik_firebase_functions_http/firebase_functions_http.dart';
import 'package:tekartik_firebase_functions_node/src/firebase_functions_firestore_node.dart';
import 'package:tekartik_firebase_functions_node/src/firebase_functions_pubsub_node.dart';

import 'firebase_functions_https_node.dart';

FirebaseFunctionsNode _firebaseFunctionsNode;

FirebaseFunctionsHttp get firebaseFunctionsNode =>
    _firebaseFunctionsNode ??= FirebaseFunctionsNode(impl.functions);

//import 'package:firebase_functions_interop/
class FirebaseFunctionsNode extends FirebaseFunctionsHttp
    implements common.FirebaseFunctions {
  final impl.FirebaseFunctions implFunctions;

  common.HttpsFunctions _https;

  @override
  common.HttpsFunctions get https => _https ??= HttpsFunctionsNode(this);

  common.FirestoreFunctions _firestore;

  @override
  common.FirestoreFunctions get firestore =>
      _firestore ??= FirestoreFunctionsNode(this);

  common.PubsubFunctions _pubsub;

  @override
  common.PubsubFunctions get pubsub => _pubsub ??= PubsubFunctionsNode(this);

  FirebaseFunctionsNode(this.implFunctions) : super();

  @override
  common.FirebaseFunctions region(String region) {
    return FirebaseFunctionsNode(implFunctions.region(region));
  }

  @override
  common.FirebaseFunctions runWith(common.RuntimeOptions options) {
    return FirebaseFunctionsNode(implFunctions.runWith(impl.RuntimeOptions(
        timeoutSeconds: options.timeoutSeconds, memory: options.memory)));
  }

  @override
  operator []=(String key, common.FirebaseFunction function) {
    implFunctions[key] = (function as FirebaseFunctionNode).value;
  }
/*
  @override
  operator []=(String key, dynamic function) {
    devPrint('function $key');
    implFunctions[key] = function;

    devPrint(jsObjectKeys(exports));
  }*/
}

abstract class FirebaseFunctionNode implements common.FirebaseFunction {
  dynamic get value;
}

String get firebaseProjectId {
  return Platform.environment['GCLOUD_PROJECT'];
}

String get firebaseStorageBucketName {
  return '$firebaseProjectId.appspot.com';
}
