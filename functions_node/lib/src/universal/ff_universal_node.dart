import 'package:tekartik_firebase_functions/ff_server.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node.dart';

class FfServerNode implements FfServer {
  @override
  Future<void> close() async {}

  @override
  Uri get uri => throw UnsupportedError('TODO?');
}

/// Node implementation
class FirebaseFunctionsNodeUniversal extends FirebaseFunctionsNode
    with FirebaseFunctionsNodeUniversalMixin {
  FirebaseFunctionsNodeUniversal();
}

/// Node implementation
mixin FirebaseFunctionsNodeUniversalMixin
    implements FirebaseFunctionsUniversal {
  /// Dummy implementation on node. Must be served using `firebase serve`
  @override
  Future<FfServer> serve({int? port}) async => FfServerNode();
}

/// V1 by default
FirebaseFunctionsUniversal firebaseFunctionsUniversal =
    FirebaseFunctionsNodeUniversal();

FirebaseFunctions get firebaseFunctions => firebaseFunctionsUniversal;
