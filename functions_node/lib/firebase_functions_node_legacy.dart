import 'package:tekartik_firebase_functions/firebase_functions.dart';

import 'src/node_legacy/firebase_functions_node.dart' as node;

export 'src/node_legacy/firebase_functions_node.dart'
    show firebaseProjectId, firebaseStorageBucketName;

FirebaseFunctions get firebaseFunctionsNode => node.firebaseFunctionsNode;
