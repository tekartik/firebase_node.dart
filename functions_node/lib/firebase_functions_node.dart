import 'package:tekartik_firebase_functions_http/firebase_functions_http.dart';
import 'package:tekartik_firebase_functions_io/firebase_functions_io.dart';

import 'src/firebase_functions_node.dart' as node;

export 'src/firebase_functions_node.dart'
    show firebaseProjectId, firebaseStorageBucketName;

FirebaseFunctionsHttp get firebaseFunctionsNode => node.firebaseFunctionsNode;
