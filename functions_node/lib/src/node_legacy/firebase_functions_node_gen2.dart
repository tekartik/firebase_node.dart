import 'package:firebase_functions_interop/firebase_functions_interop_gen2.dart'
    as gen2;

import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;

import 'package:tekartik_firebase_functions_node/src/node_legacy/firebase_functions_https_node_gen2.dart';

import 'firebase_functions_firestore_node_gen2.dart';
import 'firebase_functions_node.dart';

FirebaseFunctionsNodeGen2? _firebaseFunctionsNodeV2;

/// V2 node functions.
FirebaseFunctionsNodeGen2 get firebaseFunctionsNodeV2 =>
    _firebaseFunctionsNodeV2 ??= FirebaseFunctionsNodeGen2(gen2.functionsGen2);

//import 'package:firebase_functions_interop/
class FirebaseFunctionsNodeGen2 with common.FirebaseFunctionsDefaultMixin {
  final gen2.FirebaseFunctionsGen2 implFunctions;

  common.HttpsFunctions? _https;

  @override
  common.HttpsFunctions get https => _https ??= HttpsFunctionsNodeV2(this);

  FirestoreFunctionsNodeGen2? _firestore;

  @override
  FirestoreFunctionsNodeGen2 get firestore {
    _firestore ??= FirestoreFunctionsNodeGen2(
      this,
    );
    return _firestore!;
  }

  FirebaseFunctionsNodeGen2(this.implFunctions) : super();

  @override
  operator []=(String key, common.FirebaseFunction function) {
    implFunctions[key] = (function as FirebaseFunctionNode).value as Object;
  }
}
