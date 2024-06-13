import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_http/firebase_functions_http.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node_js_interop.dart'
    as node;

class FirebaseFunctionsNode extends FirebaseFunctionsHttp {
  final nativeInstance = node.firebaseFunctionsModule;
  @override
  void operator []=(String key, FirebaseFunction function) {
    nativeInstance[key] = (function as FirebaseFunctionNode).nativeInstance;
  }
}

abstract class FirebaseFunctionNode implements FirebaseFunction {
  FirebaseFunctionsNode get firebaseFunctionsNode;
  node.FirebaseFunction get nativeInstance;
}
