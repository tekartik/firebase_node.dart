import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:firebase_functions_interop/firebase_functions_interop_gen2.dart'
    as impl_gen2;
import 'package:tekartik_firebase_functions/ff_server.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';
import 'package:tekartik_firebase_functions_node/src/firebase_functions_node.dart';
import 'package:tekartik_firebase_functions_node/src/firebase_functions_node_gen2.dart';

class FfServerNode implements FfServer {
  @override
  Future<void> close() async {}

  @override
  Uri get uri => throw UnsupportedError('TODO?');
}

/// Node implementation
class FirebaseFunctionsNodeUniversal extends FirebaseFunctionsNode
    with FirebaseFunctionsNodeUniversalMixin {
  FirebaseFunctionsNodeUniversal(super.implFunctions);
}

/// Node implementation
mixin FirebaseFunctionsNodeUniversalMixin
    implements FirebaseFunctionsUniversal {
  /// Dummy implementation on node. Must be served using `firebase serve`
  @override
  Future<FfServer> serve({int? port}) async => FfServerNode();
}

/// Node implementation
class FirebaseFunctionsNodeUniversalGen2 extends FirebaseFunctionsNodeGen2
    with FirebaseFunctionsNodeUniversalMixin {
  FirebaseFunctionsNodeUniversalGen2(super.implFunctions);

  /// Dummy implementation on node. Must be served using `firebase serve`
  @override
  Future<FfServer> serve({int? port}) async => FfServerNode();
}

/// V1 by default
FirebaseFunctionsUniversal firebaseFunctionsUniversal =
    firebaseFunctionsUniversalV1;

FirebaseFunctionsUniversal firebaseFunctionsUniversalV1 =
    FirebaseFunctionsNodeUniversal(impl.functions);

// Temp mix of Gen2 and V1
FirebaseFunctionsUniversal firebaseFunctionsUniversalV2 =
    FirebaseFunctionsNodeUniversal(impl.functionsV2);

FirebaseFunctionsUniversal firebaseFunctionsUniversalGen2 =
    FirebaseFunctionsNodeUniversalGen2(impl_gen2.functionsGen2);

FirebaseFunctions get firebaseFunctions => firebaseFunctionsNode;
