import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_io/firebase_functions_io.dart';
import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';
import 'package:tekartik_http_io/http_server_io.dart';

FirebaseFunctions get firebaseFunctions => firebaseFunctionsIo;

class FirebaseFunctionsHttpUniversalIo extends FirebaseFunctionsHttpUniversal {
  FirebaseFunctionsHttpUniversalIo() : super(httpServerFactoryIo);
}

final FirebaseFunctionsUniversal firebaseFunctionsUniversal =
    FirebaseFunctionsHttpUniversalIo();
