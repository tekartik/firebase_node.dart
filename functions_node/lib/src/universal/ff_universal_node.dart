import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';
import 'package:tekartik_firebase_functions_node/src/firebase_functions_node.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:tekartik_firebase_functions_http/ff_server.dart';

class FfServerNode implements FfServer {
  @override
  Future<void> close() async {}

  @override
  Uri get uri => null;
}

/// Node implementation
class FirebaseFunctionsNodeUniversal extends FirebaseFunctionsNode
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsNodeUniversal(impl.FirebaseFunctions implFunctions)
      : super(implFunctions);

  /// Dummy implementation on node. Must be served using `firebase serve`
  @override
  Future<FfServer> serve({int port}) async => FfServerNode();
}

FirebaseFunctionsUniversal firebaseFunctionsUniversal =
    FirebaseFunctionsNodeUniversal(impl.functions);

FirebaseFunctions get firebaseFunctions => firebaseFunctionsNode;
