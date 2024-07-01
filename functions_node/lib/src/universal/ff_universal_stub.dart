import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';

FirebaseFunctionsServiceUniversal get firebaseFunctionsServiceUniversal =>
    throw UnsupportedError(
        'firebaseFunctionsServiceUniversal on io or node only');

/// Prefer using [firebaseFunctionsServiceUniversal.functions()]
FirebaseFunctionsUniversal get firebaseFunctionsUniversal =>
    throw UnsupportedError('firebaseFunctions on io or node only');
