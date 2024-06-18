import 'package:tekartik_firebase_functions/ff_server.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_http/ff_server.dart';
import 'package:tekartik_firebase_functions_http/src/firebase_functions_http.dart'; // ignore: implementation_imports
import 'package:tekartik_http/http_memory.dart';

/// Allow running a main as a node or io app
abstract class FirebaseFunctionsUniversal extends FirebaseFunctions {
  FirebaseFunctionsUniversal() : super();

  /// No effect on node
  Future<FfServer?> serve({int? port});
}

abstract class FirebaseFunctionsUniversalBase extends FirebaseFunctionsHttpBase
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsUniversalBase(super.httpServerFactory);

  /// No effect on node
  @override
  Future<FfServer> serve({int? port});
}

class FirebaseFunctionsHttpUniversal extends FirebaseFunctionsHttpBase
    implements FirebaseFunctionsUniversal {
  FirebaseFunctionsHttpUniversal(super.httpServerFactory);

  @override
  Future<FfServer> serve({int? port}) async {
    var httpServer = await serveHttp(port: port);
    return FfServerHttp(httpServer);
  }
}

final FirebaseFunctionsUniversal firebaseFunctionsUniversalMemory =
    FirebaseFunctionsHttpUniversal(httpServerFactoryMemory);
