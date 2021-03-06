import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart' as node;
import 'package:firebase_admin_interop/src/bindings.dart' // ignore: implementation_imports
    as js;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_firestore/firestore.dart';
import 'package:tekartik_firebase_firestore/src/common/firestore_service_mixin.dart'; // ignore: implementation_imports
import 'package:tekartik_firebase_firestore/src/firestore.dart'; // ignore: implementation_imports
import 'package:tekartik_firebase_firestore/utils/firestore_mixin.dart';
import 'package:tekartik_firebase_node/src/firebase_node.dart'; // ignore: implementation_imports

js.FirestoreSettings _unwrapSettings(FirestoreSettings settings) {
  var nativeSettings = js.FirestoreSettings(
      // ignore: deprecated_member_use
      timestampsInSnapshots: settings.timestampsInSnapshots);
  return nativeSettings;
}

class FirestoreServiceNode
    with FirestoreServiceMixin
    implements FirestoreService {
  @override
  Firestore firestore(App app) {
    return getInstance(app, () {
      assert(app is AppNode, 'invalid firebase app type');
      final appNode = app as AppNode;
      return FirestoreNode(appNode.nativeInstance!.firestore());
    });
  }

  @override
  bool get supportsQuerySelect => true;

  @override
  bool get supportsDocumentSnapshotTime => true;

  @override
  bool get supportsTimestampsInSnapshots => true;

  @override
  bool get supportsTimestamps => true;

  @override
  bool get supportsQuerySnapshotCursor => true;

  @override
  bool get supportsFieldValueArray => true;

  @override
  bool get supportsTrackChanges => true;

  @override
  String toString() => 'FirestoreServiceNode()';
}

FirestoreServiceNode? _firestoreServiceNode;
FirestoreServiceNode get firestoreServiceNode =>
    _firestoreServiceNode ??= FirestoreServiceNode();
FirestoreService get firestoreService => firestoreServiceNode;

class FirestoreNode implements Firestore {
  final node.Firestore nativeInstance;

  FirestoreNode(this.nativeInstance);

  @override
  CollectionReference collection(String path) =>
      _collectionReference(nativeInstance.collection(path));

  @override
  DocumentReference doc(String path) =>
      _wrapDocumentReference(nativeInstance.document(path))!;

  @override
  WriteBatch batch() => WriteBatchNode(nativeInstance.batch());

  @override
  Future<T> runTransaction<T>(
          FutureOr<T> Function(Transaction transaction) updateFunction) =>
      nativeInstance.runTransaction<T>((nativeTransaction) async {
        var transaction = TransactionNode(nativeTransaction);
        return await updateFunction(transaction);
      });

  @override
  void settings(FirestoreSettings settings) {
    nativeInstance.settings(_unwrapSettings(settings));
  }

  @override
  Future<List<DocumentSnapshot>> getAll(List<DocumentReference> refs) async =>
      _wrapDocumentSnapshots(
          await nativeInstance.getAll(_unwrapDocumentReferences(refs)));

  @override
  String toString() => 'FirestoreNode()';
}

FirestoreNode firestore(node.Firestore _impl) => FirestoreNode(_impl);

CollectionReferenceNode _collectionReference(node.CollectionReference _impl) =>
    CollectionReferenceNode._(_impl);

DocumentReferenceNode? _wrapDocumentReference(node.DocumentReference? _impl) =>
    _impl != null ? DocumentReferenceNode._(_impl) : null;

node.DocumentReference? _unwrapDocumentReference(DocumentReference? docRef) =>
    (docRef as DocumentReferenceNode?)?.nativeInstance;

List<node.DocumentReference> _unwrapDocumentReferences(
        Iterable<DocumentReference> docRef) =>
    docRef.map((ref) => _unwrapDocumentReference(ref)!).toList(growable: false);

class WriteBatchNode implements WriteBatch {
  final node.WriteBatch nativeInstance;

  WriteBatchNode(this.nativeInstance);

  @override
  Future commit() => nativeInstance.commit();

  @override
  void delete(DocumentReference? ref) =>
      nativeInstance.delete(_unwrapDocumentReference(ref)!);

  @override
  void set(DocumentReference ref, Map<String, dynamic> data,
          [SetOptions? options]) =>
      nativeInstance.setData(
          _unwrapDocumentReference(ref)!,
          documentDataToNativeDocumentData(DocumentData(data)),
          _unwrapSetOptions(options));

  @override
  void update(DocumentReference ref, Map<String, dynamic> data) =>
      nativeInstance.updateData(_unwrapDocumentReference(ref)!,
          documentDataToNativeUpdateData(DocumentData(data))!);
}

class QueryNode extends Object with QueryMixin {
  @override
  final node.DocumentQuery nativeInstance;

  QueryNode(this.nativeInstance);
}

abstract class QueryMixin implements Query {
  node.DocumentQuery get nativeInstance;

  @override
  Future<QuerySnapshot> get() async =>
      _wrapQuerySnapshot(await nativeInstance.get());

  @override
  Query select(List<String> fieldPaths) =>
      _wrapQuery(nativeInstance.select(fieldPaths));

  @override
  Query limit(int limit) => _wrapQuery(nativeInstance.limit(limit));

  @override
  Query orderBy(String key, {bool? descending}) =>
      _wrapQuery(nativeInstance.orderBy(key, descending: descending == true));

  @override
  QueryNode startAt({DocumentSnapshot? snapshot, List? values}) =>
      _wrapQuery(nativeInstance.startAt(
          snapshot: _unwrapDocumentSnapshot(snapshot),
          values: _unwrapValues(values)));

  @override
  Query startAfter({DocumentSnapshot? snapshot, List? values}) =>
      _wrapQuery(nativeInstance.startAfter(
          snapshot: _unwrapDocumentSnapshot(snapshot),
          values: _unwrapValues(values)));

  @override
  QueryNode endAt({DocumentSnapshot? snapshot, List? values}) =>
      _wrapQuery(nativeInstance.endAt(
          snapshot: _unwrapDocumentSnapshot(snapshot),
          values: _unwrapValues(values)));

  @override
  QueryNode endBefore({DocumentSnapshot? snapshot, List? values}) =>
      _wrapQuery(nativeInstance.endBefore(
          snapshot: _unwrapDocumentSnapshot(snapshot),
          values: _unwrapValues(values)));

  @override
  QueryNode where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    bool? isNull,
  }) {
    if (arrayContainsAny != null) {
      throw UnsupportedError('arrayContainsAny');
    }
    if (whereIn != null) {
      throw UnsupportedError('whereIn');
    }
    return _wrapQuery(nativeInstance.where(fieldPath,
        isEqualTo: _unwrapValue(isEqualTo),
        isLessThan: _unwrapValue(isLessThan),
        isLessThanOrEqualTo: _unwrapValue(isLessThanOrEqualTo),
        isGreaterThan: _unwrapValue(isGreaterThan),
        isGreaterThanOrEqualTo: _unwrapValue(isGreaterThanOrEqualTo),
        arrayContains: _unwrapValue(arrayContains),
        isNull: isNull));
  }

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (node.QuerySnapshot nativeQuerySnapshot,
            EventSink<QuerySnapshot> sink) {
      sink.add(_wrapQuerySnapshot(nativeQuerySnapshot));
    });
    return nativeInstance.snapshots.transform(transformer);
  }
}

class CollectionReferenceNode extends QueryNode implements CollectionReference {
  @override
  node.CollectionReference get nativeInstance =>
      super.nativeInstance as node.CollectionReference;

  CollectionReferenceNode._(node.CollectionReference implCollectionReference)
      : super(implCollectionReference);

  @override
  DocumentReference doc([String? path]) =>
      _wrapDocumentReference(nativeInstance.document(path))!;

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async =>
      _wrapDocumentReference(await nativeInstance
          .add(documentDataToNativeDocumentData(DocumentData(data))))!;

  @override
  // ignore: invalid_use_of_protected_member
  String get id => nativeInstance.nativeInstance!.id;

  @override
  DocumentReference? get parent =>
      _wrapDocumentReference(nativeInstance.parent);

  @override
  // ignore: invalid_use_of_protected_member
  String get path => nativeInstance.nativeInstance!.path;

  @override
  String toString() {
    return 'CollectionReferenceNode($path)';
  }

  /// Equality based on path
  @override
  int get hashCode => path.hashCode;

  /// Equality based on path
  @override
  bool operator ==(Object other) {
    if (other is CollectionReference) {
      return other.path == path;
    }
    return false;
  }
}

/// Unwrap list for startAt, endAt...
List? _unwrapValues(List? values) =>
    values?.map(_unwrapValue).toList(growable: false);

dynamic _unwrapValue(value) {
  if (value == null || value is num || value is bool || value is String) {
    return value;
  } else if (value is DateTime) {
    return value;
  } else if (value is Timestamp) {
    return node.Timestamp(value.seconds, value.nanoseconds);
  } else if (value is Map) {
    return value.map((key, value) => MapEntry(key, _unwrapValue(value)));
  } else if (value is List) {
    return value.map(_unwrapValue).toList(growable: false);
  } else {
    throw ArgumentError.value(
        value, '${value.runtimeType}', 'Unsupported value for _unwrapValue');
  }
}

/*
js.Timestamp _createJsTimestamp(Timestamp ts) {
  return js.callConstructor(
      firebaseNode.nativeInstance.admin.firestore.Timestamp, jsify([ts.seconds, ts.nanoseconds]) as List) as js.Timestamp;
}
*/

List listToNative(Iterable list) {
  return list.map((value) => documentValueToNativeValue(value)).toList();
}

dynamic documentValueToNativeValue(dynamic value) {
  if (value == null ||
      value is num ||
      value is bool ||
      value is String ||
      value is DateTime) {
    return value;
  } else if (value is Timestamp) {
    return node.Timestamp(value.seconds, value.nanoseconds);
  } else if (value is FieldValue) {
    if (value == FieldValue.delete) {
      return node.Firestore.fieldValues.delete();
    } else if (value == FieldValue.serverTimestamp) {
      return node.Firestore.fieldValues.serverTimestamp();
    } else if (value is FieldValueArray) {
      if (value.type == FieldValueType.arrayUnion) {
        return node.Firestore.fieldValues.arrayUnion(listToNative(value.data));
      } else if (value.type == FieldValueType.arrayRemove) {
        return node.Firestore.fieldValues.arrayRemove(listToNative(value.data));
      }
    }
  } else if (value is Iterable) {
    return listToNative(value);
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        MapEntry(key as String, documentValueToNativeValue(value)));
  } else if (value is DocumentReferenceNode) {
    return value.nativeInstance;
  } else if (value is GeoPoint) {
    return node.GeoPoint(value.latitude.toDouble(), value.longitude.toDouble());
  } else if (value is Blob) {
    return node.Blob.fromUint8List(value.data);
  } else {
    throw ArgumentError.value(value, '${value.runtimeType}',
        'Unsupported value for documentValueToNativeValue');
  }
}

dynamic documentValueFromNativeValue(dynamic value) {
  if (value == null ||
      value is num ||
      value is bool ||
      value is String ||
      value is DateTime) {
    return value;
  } else if (value is node.Timestamp) {
    return Timestamp(value.seconds, value.nanoseconds);
  } else if (value == node.Firestore.fieldValues.delete()) {
    return FieldValue.delete;
  } else if (value == node.Firestore.fieldValues.serverTimestamp()) {
    return FieldValue.serverTimestamp;
  } else if (value is List) {
    return value.map((value) => documentValueFromNativeValue(value)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        MapEntry(key as String, documentValueFromNativeValue(value)));
  } else if (value is node.GeoPoint) {
    return GeoPoint(value.latitude, value.longitude);
  } else if (value is node.Blob) {
    return Blob(value.asUint8List());
  } else if (value is node.DocumentReference) {
    return DocumentReferenceNode._(value);
  } else {
    throw ArgumentError.value(value, '${value.runtimeType}',
        'Unsupported value for documentValueFromNativeValue');
  }
}

node.DocumentData documentDataToNativeDocumentData(DocumentData documentData) {
  var map = (documentData as DocumentDataMap).map;
  var nativeMap = documentValueToNativeValue(map) as Map<String, dynamic>;
  final nativeInstance = node.DocumentData.fromMap(nativeMap);
  return nativeInstance;
}

DocumentData documentDataFromNativeDocumentData(
    node.DocumentData nativeInstance) {
  var nativeMap = nativeInstance.toMap();
  var map = documentValueFromNativeValue(nativeMap) as Map<String, dynamic>;
  var documentData = DocumentData(map);
  return documentData;
}

node.UpdateData? documentDataToNativeUpdateData(DocumentData documentData) {
  var map = (documentData as DocumentDataMap).map;
  var nativeMap = documentValueToNativeValue(map) as Map<String, dynamic>;
  final nativeInstance = node.UpdateData.fromMap(nativeMap);
  return nativeInstance;
}

class DocumentReferenceNode implements DocumentReference {
  final node.DocumentReference nativeInstance;

  DocumentReferenceNode._(this.nativeInstance);

  @override
  CollectionReference collection(path) =>
      _collectionReference(nativeInstance.collection(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions? options]) async {
    await nativeInstance.setData(
        documentDataToNativeDocumentData(DocumentData(data)),
        _unwrapSetOptions(options));
  }

  @override
  Future<DocumentSnapshot> get() async =>
      _wrapDocumentSnapshot(await nativeInstance.get());

  @override
  Future delete() async {
    await nativeInstance.delete();
  }

  @override
  Future update(Map<String, dynamic> data) async {
    await nativeInstance
        .updateData(documentDataToNativeUpdateData(DocumentData(data))!);
  }

  @override
  String get id => nativeInstance.documentID;

  @override
  CollectionReference get parent =>
      _collectionReference(node.CollectionReference(
          // ignore: invalid_use_of_protected_member
          nativeInstance.nativeInstance.parent,
          nativeInstance.firestore));

  @override
  String get path => nativeInstance.path;

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (node.DocumentSnapshot nativeDocumentSnapshot,
            EventSink<DocumentSnapshot> sink) {
      sink.add(_wrapDocumentSnapshot(nativeDocumentSnapshot));
    });
    return nativeInstance.snapshots.transform(transformer);
  }

  @override
  String toString() {
    return 'DocumentReferenceNode($path)';
  }

  /// Equality based on path
  @override
  int get hashCode => path.hashCode;

  /// Equality based on path
  @override
  bool operator ==(Object other) {
    if (other is DocumentReference) {
      return other.path == path;
    }
    return false;
  }
}

class DocumentSnapshotNode implements DocumentSnapshot {
  final node.DocumentSnapshot nativeInstance;

  DocumentSnapshotNode(this.nativeInstance);

  @override
  Map<String, dynamic> get data => (exists
      ? documentDataFromNativeDocumentData(nativeInstance.data).asMap()
      : null)!;

  @override
  DocumentReference get ref =>
      _wrapDocumentReference(nativeInstance.reference)!;

  @override
  bool get exists => nativeInstance.exists;

  @override
  Timestamp? get updateTime => _wrapTimestamp(nativeInstance.updateTime);

  @override
  Timestamp? get createTime => _wrapTimestamp(nativeInstance.createTime);

  @override
  String toString() {
    return 'DocumentSnapshotNode(ref: $ref)';
  }
}

Timestamp? _wrapTimestamp(node.Timestamp? nativeInstance) =>
    nativeInstance != null
        ? Timestamp(nativeInstance.seconds, nativeInstance.nanoseconds)
        : null;

DocumentChangeType _wrapDocumentChangeType(node.DocumentChangeType type) {
  switch (type) {
    case node.DocumentChangeType.added:
      return DocumentChangeType.added;
    case node.DocumentChangeType.removed:
      return DocumentChangeType.removed;
    case node.DocumentChangeType.modified:
      return DocumentChangeType.modified;
  }
}

class DocumentChangeNode implements DocumentChange {
  final node.DocumentChange nativeInstance;

  DocumentChangeNode(this.nativeInstance);

  @override
  DocumentSnapshot get document =>
      _wrapDocumentSnapshot(nativeInstance.document);

  @override
  int get newIndex => nativeInstance.newIndex;

  @override
  int get oldIndex => nativeInstance.oldIndex;

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type!);
}

class QuerySnapshotNode implements QuerySnapshot {
  final node.QuerySnapshot nativeInstance;

  QuerySnapshotNode._(this.nativeInstance);

  @override
  List<DocumentSnapshot> get docs {
    var implDocs = nativeInstance.documents;
    if (implDocs == null) {
      return <DocumentSnapshot>[];
    }
    var docs = <DocumentSnapshot?>[];
    for (var implDocumentSnapshot in implDocs) {
      docs.add(_wrapDocumentSnapshot(implDocumentSnapshot));
    }
    return docs.cast<DocumentSnapshot>();
  }

  @override
  List<DocumentChange> get documentChanges {
    var changes = <DocumentChange>[];
    if (nativeInstance.documentChanges != null) {
      for (var nativeChange in nativeInstance.documentChanges!) {
        changes.add(DocumentChangeNode(nativeChange));
      }
    }
    return changes;
  }
}

class TransactionNode implements Transaction {
  final node.Transaction nativeInstance;

  TransactionNode(this.nativeInstance);
  @override
  void delete(DocumentReference documentRef) {
    nativeInstance.delete(_unwrapDocumentReference(documentRef)!);
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) async =>
      _wrapDocumentSnapshot(
          await nativeInstance.get(_unwrapDocumentReference(documentRef)!));

  @override
  void set(DocumentReference documentRef, Map<String, dynamic> data,
      [SetOptions? options]) {
    nativeInstance.set(_unwrapDocumentReference(documentRef)!,
        documentDataToNativeDocumentData(DocumentData(data)),
        merge: options?.merge ?? false);
  }

  @override
  void update(DocumentReference documentRef, Map<String, dynamic> data) {
    nativeInstance.update(_unwrapDocumentReference(documentRef)!,
        documentDataToNativeUpdateData(DocumentData(data))!);
  }
}

QueryNode _wrapQuery(node.DocumentQuery nativeInstance) =>
    QueryNode(nativeInstance);

DocumentSnapshotNode _wrapDocumentSnapshot(
        node.DocumentSnapshot nativeInstance) =>
    DocumentSnapshotNode(nativeInstance);

List<DocumentSnapshotNode> _wrapDocumentSnapshots(
        Iterable<node.DocumentSnapshot> nativeInstances) =>
    nativeInstances.map(_wrapDocumentSnapshot).toList(growable: false);

node.DocumentSnapshot? _unwrapDocumentSnapshot(DocumentSnapshot? snapshot) =>
    snapshot != null ? (snapshot as DocumentSnapshotNode).nativeInstance : null;

QuerySnapshotNode _wrapQuerySnapshot(node.QuerySnapshot nativeInstance) =>
    QuerySnapshotNode._(nativeInstance);

node.SetOptions? _unwrapSetOptions(SetOptions? options) =>
    options != null ? node.SetOptions(merge: options.merge == true) : null;
