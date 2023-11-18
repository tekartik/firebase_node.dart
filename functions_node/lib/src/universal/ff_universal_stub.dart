import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';

FirebaseFunctionsUniversal get firebaseFunctionsUniversal =>
    throw UnsupportedError('firebaseFunctions on io or node only');
FirebaseFunctions get firebaseFunctions =>
    throw UnsupportedError('firebaseFunctions on io or node only');

FirebaseFunctionsUniversal get firebaseFunctionsUniversalV1 =>
    throw UnsupportedError('firebaseFunctionsV1 on io or node only');

/// Firebase functions V2 support (deprecated).
FirebaseFunctions get firebaseFunctionsUniversalV2 =>
    throw UnsupportedError('firebaseFunctionsV2 on io or node only');

/// Firebase functions Gen2 support.
FirebaseFunctions get firebaseFunctionsUniversalGen2 =>
    throw UnsupportedError('firebaseFunctionsUniversalGen2 on io or node only');
