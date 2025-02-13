import 'package:tekartik_firebase_firestore/firestore.dart' as fbfirestore;
// ignore: implementation_imports
import 'package:tekartik_firebase_firestore_node/src/node/firestore_node.dart'
    as fbfirestore;

// ignore: implementation_imports
import 'package:tekartik_firebase_firestore_node/src/node/firestore_node_js_interop.dart'
    as firestore_node;
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_firestore_node_js_interop.dart'
    as node;
import 'package:tekartik_firebase_node/firebase_node_interop.dart'
    as fbfirebase;

import 'firebase_functions_node.dart';

class FirestoreFunctionsNode
    with FirestoreFunctionsDefaultMixin
    implements FirestoreFunctions {
  /// Our global firestore instance
  late final fbfirestore.FirestoreNode firestore =
      fbfirestore.firestoreServiceNode.firestore(fbfirebase.firebaseNode.app())
          as fbfirestore.FirestoreNode;
  final FirebaseFunctionsNode functions;
  final node.JSFirestoreFunctions nativeInstance;

  FirestoreFunctionsNode(this.functions, this.nativeInstance);

  @override
  DocumentBuilderNode document(String path) {
    return DocumentBuilderNode(this, path);

    //
  }
}

class FirestoreFunctionNode extends FirebaseFunctionNode
    implements FirestoreFunction {
  @override
  final node.JSFirestoreFunction nativeInstance;

  FirestoreFunctionNode(super.firebaseFunctionsNode, this.nativeInstance);
}

class EventContextCompat implements EventContext {
  @override
  final String eventType;

  @override
  final Map<String, String> params;

  @override
  final fbfirestore.Timestamp timestamp;

  EventContextCompat({
    required this.eventType,
    required this.params,
    required this.timestamp,
  });
}

class DocumentBuilderNode
    with DocumentBuilderDefaultMixin
    implements DocumentBuilder {
  final String path;
  FirestoreFunctionsNode firestoreFunctions;

  fbfirestore.FirestoreNode get firestore => firestoreFunctions.firestore;

  DocumentBuilderNode(this.firestoreFunctions, this.path);

  //firestore.Firestore get firestore => firestoreFunctions.firestore;

  @override
  FirestoreFunction onWrite(ChangeEventHandler<DocumentSnapshot> handler) {
    return FirestoreFunctionNode(
      firebaseFunctionsNode,
      firestoreFunctions.nativeInstance.onDocumentWritten(
        options: node.JSDocumentOptions(document: path),
        handler: (event) {
          var data = event.data;

          /// Important to return the handler content here so that the function does not end
          return handler(
            DocumentSnapshotChangeNode(firestore, data as node.JSChange),
            EventContextCompat(
              eventType: 'onWrite',
              params: {},
              timestamp: fbfirestore.Timestamp.now(),
            ),
          );
        },
      ),
    );
  }

  /*
  @override
  FirestoreFunction onCreate(DataEventHandler<DocumentSnapshot> handler) {

    return FirestoreFunctionNodeGen2(
        firebaseFunctionsNode,
        firestoreFunctions.nativeInstance.onDocumentWritten(
            options: node.JSDocumentOptions(document: path),
            handler: (event) {
              throw UnimplementedError('onDocumentWritten');
            }));
  }*/
  /*
  @override
  FirestoreFunction onUpdate(ChangeEventHandler<DocumentSnapshot> handler) {

    return FirestoreFunctionNodeGen2(
        firestoreFunctions.impl.onDocumentWritten(path, (context) {
      throw UnimplementedError('onDocumentWritten');
    }));
  }

  @override
  FirestoreFunction onDelete(DataEventHandler<DocumentSnapshot> handler) {
    return FirestoreFunctionNodeGen2(
        firestoreFunctions.impl.onDocumentWritten(path, (context) {
      throw UnimplementedError('onDocumentWritten');
    }));
  }*/
}

abstract class ChangeNode<T> implements Change<T> {
  final fbfirestore.FirestoreNode firestore;
  final node.JSChange implChange;

  ChangeNode(this.firestore, this.implChange);

  @override
  T get after => throw UnimplementedError('ChangeNode.after');

  @override
  T get before => throw UnimplementedError('ChangeNode.before');

  @override
  String toString() {
    return {'after': after, 'before': before}.toString();
  }
}

class DocumentSnapshotChangeNode
    extends ChangeNode<fbfirestore.DocumentSnapshot> {
  DocumentSnapshotChangeNode(super.firestore, super.implChange);

  @override
  fbfirestore.DocumentSnapshot get after => fbfirestore.DocumentSnapshotNode(
    firestore,
    implChange.after as firestore_node.DocumentSnapshot,
  );

  @override
  fbfirestore.DocumentSnapshot get before => fbfirestore.DocumentSnapshotNode(
    firestore,
    implChange.after as firestore_node.DocumentSnapshot,
  );
}

/*
class EventContextNode implements EventContext {
  final impl.EventContext implEventContext;

  EventContextNode(this.implEventContext);

  @override
  String get eventType => implEventContext.eventType;

  @override
  Map<String, String> get params => implEventContext.params;

  /// Timestamp for the event.
  @override
  fbfirestore.Timestamp get timestamp =>
      fbfirestore.Timestamp.fromDateTime(implEventContext.timestamp);

  @override
  String toString() {
    return {'eventType': eventType, 'params': params, 'timestamp': timestamp}
        .toString();
  }
}
*/
