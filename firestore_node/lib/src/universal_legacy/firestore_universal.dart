export 'firestore_universal_stub.dart'
    if (dart.library.js_interop) 'firestore_universal_node.dart'
    if (dart.library.io) 'firestore_universal_io.dart';
