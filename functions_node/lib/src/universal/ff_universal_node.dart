import 'package:tekartik_firebase_functions/ff_server.dart';
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node.dart';

class FfServerNode implements FfServer {
  @override
  Future<void> close() async {}

  @override
  Uri get uri => throw UnsupportedError('TODO?');
}

class FirebaseFunctionsServiceUniversalNode
    with FirebaseProductServiceMixin, FirebaseFunctionsServiceDefaultMixin
    implements FirebaseFunctionsServiceUniversal {
  /// App unused here on nocde
  @override
  FirebaseFunctionsNodeUniversal functions(FirebaseApp app) =>
      defaultFunctions();

  @override
  FirebaseFunctionsNodeUniversal defaultFunctions() {
    return FirebaseFunctionsNodeUniversal();
  }
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
final FirebaseFunctionsUniversal firebaseFunctionsUniversal =
    firebaseFunctionsServiceUniversal.defaultFunctions();

/// V1 by default
final FirebaseFunctionsServiceUniversal firebaseFunctionsServiceUniversal =
    FirebaseFunctionsServiceUniversalNode();
