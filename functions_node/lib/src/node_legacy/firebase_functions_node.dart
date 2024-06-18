import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_firestore_node/firestore_node.dart'
    as firestore_node;
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_firebase_functions_node/src/node_legacy/firebase_functions_firestore_node.dart';
import 'package:tekartik_firebase_functions_node/src/node_legacy/firebase_functions_pubsub_node.dart';
import 'package:tekartik_firebase_node/firebase_node.dart' as firebase_node;

import 'firebase_functions_https_node.dart';
import 'import_node.dart';

FirebaseFunctionsNode? _firebaseFunctionsNode;

FirebaseFunctions get firebaseFunctionsNode =>
    _firebaseFunctionsNode ??= FirebaseFunctionsNode(impl.functions);

/// V2 node functions.
FirebaseFunctions get firebaseFunctionsNodeV2 =>
    _firebaseFunctionsNode ??= FirebaseFunctionsNode(impl.functionsV2);

//import 'package:firebase_functions_interop/
class FirebaseFunctionsNode
    with FirebaseFunctionsDefaultMixin
    implements common.FirebaseFunctions {
  final impl.FirebaseFunctions implFunctions;

  common.HttpsFunctions? _https;

  @override
  common.HttpsFunctions get https => _https ??= HttpsFunctionsNode(this);

  common.FirestoreFunctions? _firestore;

  @override
  common.FirestoreFunctions get firestore {
    _firestore ??= FirestoreFunctionsNode(
        firestore_node.firestoreServiceNode
            .firestore(firebase_node.firebaseNode.app()),
        this);

    return _firestore!;
  }

  common.PubsubFunctions? _pubsub;

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
    implFunctions[key] = (function as FirebaseFunctionNode).value as Object;
  }

  @override
  common.Params get params => _ParamsNode(implFunctions.params);
}

class _ParamsNode implements common.Params {
  final impl.Params _params;

  _ParamsNode(this._params);

  @override
  String get projectId => _params.projectId;
}

abstract class FirebaseFunctionNode implements common.FirebaseFunction {
  dynamic get value;
}

String? get firebaseProjectId {
  return Platform.environment['GCLOUD_PROJECT'];
}

String get firebaseStorageBucketName {
  return '$firebaseProjectId.appspot.com';
}
