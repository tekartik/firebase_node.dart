import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_http/src/firebase_functions_http.dart'; // ignore: implementation_imports
import 'package:tekartik_firebase_functions_http/ff_server.dart';

/// Allow running a main as a node or io app
abstract class FirebaseFunctionsUniversal extends FirebaseFunctionsHttp {
  FirebaseFunctionsUniversal() : super();

  /// No effect on node
  Future<FfServer> serve({int port});
}

abstract class FirebaseFunctionsUniversalBase extends FirebaseFunctionsHttpBase
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsUniversalBase(HttpServerFactory httpServerFactory)
      : super(httpServerFactory);

  /// No effect on node
  @override
  Future<FfServer> serve({int port});
}

class FirebaseFunctionsHttpUniversal extends FirebaseFunctionsHttpBase
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsHttpUniversal(HttpServerFactory httpServerFactory)
      : super(httpServerFactory);

  @override
  Future<FfServer> serve({int port}) async {
    var httpServer = await serveHttp(port: port);
    if (httpServer != null) {
      return FfServerHttp(httpServer);
    }
    return null;
  }
}

final FirebaseFunctionsUniversal firebaseFunctionsUniversalMemory =
    FirebaseFunctionsHttpUniversal(httpServerFactoryMemory);
