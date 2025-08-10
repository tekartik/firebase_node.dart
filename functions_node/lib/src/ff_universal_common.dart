import 'package:tekartik_firebase_functions/ff_server.dart';
import 'package:tekartik_firebase_functions_http/ff_server.dart';
import 'package:tekartik_firebase_functions_http/firebase_functions_memory.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_http/http_memory.dart';

import 'universal/ff_universal.dart';

FirebaseFunctions get firebaseFunctions => firebaseFunctionsUniversal;

abstract class FirebaseFunctionsServiceUniversal
    implements FirebaseFunctionsService {
  @override
  FirebaseFunctionsUniversal functions(FirebaseApp app);

  /// Node only.
  FirebaseFunctionsUniversal defaultFunctions();
}

/// Allow running a main as a node or io app
abstract class FirebaseFunctionsUniversal extends FirebaseFunctions {
  FirebaseFunctionsUniversal() : super();
}

abstract class FirebaseFunctionsUniversalBase extends FirebaseFunctionsHttpBase
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsUniversalBase(
    super.firebaseFunctionsService,
    super.firebaseApp,
    super.httpServerFactory,
  );

  /// No effect on node
  @override
  Future<FfServer> serve({int? port});
}

class FirebaseFunctionsHttpUniversal extends FirebaseFunctionsUniversalBase
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsHttpUniversal(
    super.firebaseFunctionsService,
    super.firebaseApp,
    super.httpServerFactory,
  );

  @override
  Future<FfServer> serve({int? port}) async {
    var httpServer = await serveHttp(port: port);
    return FfServerHttp(httpServer);
  }
}

final FirebaseFunctionsUniversal firebaseFunctionsUniversalMemory =
    FirebaseFunctionsHttpUniversal(
      firebaseFunctionsServiceMemory,
      newFirebaseAppLocal(),
      httpServerFactoryMemory,
    );

/// Extension to expose the serve method.
extension FirebaseFunctionsUniversalExt on FirebaseFunctions {
  Future<FfServer> serveUniversal({int? port}) =>
      (this as FirebaseFunctionsUniversal).serve(port: port);
}
