export 'firebase_universal_stub.dart'
    if (dart.library.js_interop) 'firebase_universal_node.dart'
    if (dart.library.io) 'firebase_universal_io.dart';
