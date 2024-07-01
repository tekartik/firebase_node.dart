import 'package:tekartik_firebase_functions_node/src/ff_universal_common.dart';

import 'ff_universal.dart';

export 'ff_universal_stub.dart'
    if (dart.library.js_interop) 'ff_universal_node.dart'
    if (dart.library.io) 'ff_universal_io.dart';

@Deprecated('Use firebaseFunctionsUniversal')
FirebaseFunctionsUniversal get firebaseFunctionsUniversalV1 =>
    firebaseFunctionsUniversal;

@Deprecated('Use firebaseFunctionsUniversal')
FirebaseFunctionsUniversal get firebaseFunctionsUniversalV2 =>
    firebaseFunctionsUniversal;

/// Shortcut.
FirebaseFunctionsServiceUniversal get firebaseFunctionsService =>
    firebaseFunctionsServiceUniversal;

/// Shortcut.
FirebaseFunctionsUniversal get firebaseFunctions => firebaseFunctionsUniversal;
