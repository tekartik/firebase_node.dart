import 'package:firebase_admin_interop/firebase_admin_interop.dart' as node;
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as impl;
import 'package:firebase_functions_interop/firebase_functions_interop_gen2.dart'
    as impl_gen2;
import 'package:tekartik_firebase_firestore/firestore.dart'
    as firebase_firestore;
import 'package:tekartik_firebase_firestore_node/src/node_legacy/firestore_node.dart' // ignore: implementation_imports
    as firestore_node;
import 'package:tekartik_firebase_functions/firebase_functions.dart' as common;
import 'package:tekartik_firebase_node/firebase_node.dart' as firebase_node;

import 'firebase_functions_node.dart';
import 'firebase_functions_node_gen2.dart';

class FirestoreFunctionsNodeGen2 implements common.FirestoreFunctions {
  late final firebase_firestore.Firestore firestore = firestore_node
      .firestoreServiceNode
      .firestore(firebase_node.firebaseNode.app());
  final FirebaseFunctionsNodeGen2 functions;
  late impl_gen2.FirestoreFunctionsGen2 impl;

  FirestoreFunctionsNodeGen2(this.functions) {
    impl = functions.implFunctions.firestore;
  }

  @override
  common.DocumentBuilder document(String path) {
    return DocumentBuilderNodeGen2(this, path);

    //
  }
}

class FirestoreFunctionNodeGen2 extends FirebaseFunctionNode
    implements common.FirestoreFunction {
  final dynamic implCloudFunction;

  FirestoreFunctionNodeGen2(this.implCloudFunction);

  @override
  dynamic get value => implCloudFunction;
}

class EventContextCompat implements common.EventContext {
  @override
  final String eventType;

  @override
  final Map<String, String> params;

  @override
  final firebase_firestore.Timestamp timestamp;

  EventContextCompat(
      {required this.eventType, required this.params, required this.timestamp});
}

class DocumentBuilderNodeGen2 implements common.DocumentBuilder {
  final String path;
  FirestoreFunctionsNodeGen2 firestoreFunctions;

  DocumentBuilderNodeGen2(this.firestoreFunctions, this.path);

  firebase_firestore.Firestore get firestore => firestoreFunctions.firestore;

  @override
  common.FirestoreFunction onWrite(
      common.ChangeEventHandler<common.DocumentSnapshot> handler) {
    return FirestoreFunctionNodeGen2(
        firestoreFunctions.impl.onDocumentWritten(path, (event) {
      var data = event.data;

      /// Important to return the handler content here so that the function does not end
      return handler(
          DocumentSnapshotChangeNode(firestore, data),
          EventContextCompat(
              eventType: 'onWrite',
              params: {},
              timestamp: firebase_firestore.Timestamp.now()));
    }));
  }

  @override
  common.FirestoreFunction onCreate(
      common.DataEventHandler<common.DocumentSnapshot> handler) {
    /*
    return FirestoreFunctionNode(implBuilder.onCreate((data, context) {
      /// Important to return the handler content here so that the function does not end
      return handler(firestore_node.DocumentSnapshotNode(firestore, data),
          EventContextNode(context));
    }));

     */
    return FirestoreFunctionNodeGen2(
        firestoreFunctions.impl.onDocumentWritten(path, (context) {
      throw UnimplementedError('onDocumentWritten');
    }));
  }

  @override
  common.FirestoreFunction onUpdate(
      common.ChangeEventHandler<common.DocumentSnapshot> handler) {
    /*
    return FirestoreFunctionNode(implBuilder.onUpdate((data, context) {
      /// Important to return the handler content here so that the function does not end
      return handler(DocumentSnapshotChangeNode(firestore, data),
          EventContextNode(context));
    }));*/
    return FirestoreFunctionNodeGen2(
        firestoreFunctions.impl.onDocumentWritten(path, (context) {
      throw UnimplementedError('onDocumentWritten');
    }));
  }

  @override
  common.FirestoreFunction onDelete(
      common.DataEventHandler<common.DocumentSnapshot> handler) {
    /*
    return FirestoreFunctionNode(implBuilder.onDelete((data, context) {
      /// Important to return the handler content here so that the function does not end
      return handler(firestore_node.DocumentSnapshotNode(firestore, data),
          EventContextNode(context));
    }));

     */
    return FirestoreFunctionNodeGen2(
        firestoreFunctions.impl.onDocumentWritten(path, (context) {
      throw UnimplementedError('onDocumentWritten');
    }));
  }
}

abstract class ChangeNode<T> implements common.Change<T> {
  final firebase_firestore.Firestore firestore;
  final impl.Change implChange;

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
    extends ChangeNode<firebase_firestore.DocumentSnapshot> {
  DocumentSnapshotChangeNode(super.firestore, super.implChange);

  @override
  firebase_firestore.DocumentSnapshot get after =>
      firestore_node.DocumentSnapshotNode(
          firestore, implChange.after as node.DocumentSnapshot);

  @override
  firebase_firestore.DocumentSnapshot get before =>
      firestore_node.DocumentSnapshotNode(
          firestore, implChange.after as node.DocumentSnapshot);
}

class EventContextNode implements common.EventContext {
  final impl.EventContext implEventContext;

  EventContextNode(this.implEventContext);

  @override
  String get eventType => implEventContext.eventType;

  @override
  Map<String, String> get params => implEventContext.params;

  /// Timestamp for the event.
  @override
  firebase_firestore.Timestamp get timestamp =>
      firebase_firestore.Timestamp.fromDateTime(implEventContext.timestamp);

  @override
  String toString() {
    return {'eventType': eventType, 'params': params, 'timestamp': timestamp}
        .toString();
  }
}
