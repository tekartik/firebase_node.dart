import 'package:tekartik_firebase_functions/ff_server.dart';
// ignore: implementation_imports
//import 'package:tekartik_firebase_functions/src/ff_server.dart';
import 'package:tekartik_firebase_functions_http/ff_server.dart';
import 'package:tekartik_firebase_functions_http/firebase_functions_http.dart';
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';
import 'package:tekartik_http_io/http_server_io.dart';

class FirebaseFunctionsServiceHttpUniversalIo
    with
        FirebaseProductServiceMixin<FirebaseFunctions>,
        FirebaseFunctionsServiceDefaultMixin
    implements FirebaseFunctionsServiceUniversal, FirebaseFunctionsServiceHttp {
  @override
  FirebaseFunctionsHttpUniversalIo functions(FirebaseApp app) =>
      FirebaseFunctionsHttpUniversalIo._(this, app);

  /// Default implementation if not accessing firebase services.
  @override
  FirebaseFunctionsHttpUniversalIo defaultFunctions() =>
      FirebaseFunctionsHttpUniversalIo._(this, newFirebaseAppLocal());
}

final firebaseFunctionsServiceIo = FirebaseFunctionsServiceHttpUniversalIo();

class FirebaseFunctionsHttpUniversalIo extends FirebaseFunctionsUniversalBase {
  FirebaseFunctionsHttpUniversalIo._(
    FirebaseFunctionsServiceHttp firebaseFunctionsService,
    FirebaseApp firebaseApp,
  ) : super(firebaseFunctionsService, firebaseApp, httpServerFactoryIo);

  @override
  Future<FfServer> serve({int? port}) async {
    var httpServer = await serveHttp(port: port);
    return FfServerHttp(httpServer);
  }
}

final FirebaseFunctionsUniversal firebaseFunctionsUniversal =
    firebaseFunctionsServiceUniversal.defaultFunctions();

final FirebaseFunctionsServiceHttpUniversalIo _finalFirebaseFunctionsServiceIo =
    FirebaseFunctionsServiceHttpUniversalIo();

FirebaseFunctionsServiceUniversal get firebaseFunctionsServiceUniversal =>
    _finalFirebaseFunctionsServiceIo;
