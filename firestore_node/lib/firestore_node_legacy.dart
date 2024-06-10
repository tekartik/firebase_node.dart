import 'package:tekartik_firebase_firestore/firestore.dart';
import 'package:tekartik_firebase_firestore_node/src/node_legacy/firestore_node_legacy.dart'
    as firestore_node;

FirestoreService get firestoreServiceNode => firestore_node.firestoreService;
