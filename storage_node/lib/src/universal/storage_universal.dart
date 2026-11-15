export 'storage_universal_stub.dart'
    if (dart.library.js_interop) 'storage_universal_node.dart'
    if (dart.library.io) 'storage_universal_io.dart';
