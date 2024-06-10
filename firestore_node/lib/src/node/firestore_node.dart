library wip;

/*
import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';
import 'package:tekartik_js_utils_interop/js_date.dart' as js;
import 'package:tekartik_js_utils_interop/js_number.dart' as js;
import 'package:tekartik_firebase_firestore/firestore.dart';
import 'package:tekartik_firebase_firestore_node/src/import_firestore.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'firestore_node_js_interop.dart' as js;
import 'firestore_node_js_interop.dart' as node;
import 'package:tekartik_firebase_node/src/node/firebase_node.dart'
    show AppNode, FirebaseNode;

node.FirestoreSettings _unwrapSettings(FirestoreSettings settings) {
  var nativeSettings = node.FirestoreSettings(
      // ignore: deprecated_member_use
      timestampsInSnapshots: settings.timestampsInSnapshots);
  return nativeSettings;
}

class FirestoreServiceNode
    with FirestoreServiceDefaultMixin, FirestoreServiceMixin
    implements FirestoreService {
  @override
  Firestore firestore(App app) {
    return getInstance(app, () {
      assert(app is AppNode, 'invalid firebase app type');
      final appNode = app as AppNode;
      return FirestoreNode(
          this, node.firestoreModule.getFirestore(appNode.nativeInstance!));
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
  bool get supportsListCollections => true;

  @override
  bool get supportsAggregateQueries => true;

  @override
  String toString() => 'FirestoreServiceNode()';
}

FirestoreServiceNode? _firestoreServiceNode;

FirestoreServiceNode get firestoreServiceNode =>
    _firestoreServiceNode ??= FirestoreServiceNode();

FirestoreService get firestoreService => firestoreServiceNode;

class FirestoreNode with FirestoreDefaultMixin implements Firestore {
  @override
  final FirestoreServiceNode service;
  final node.Firestore nativeInstance;

  FirestoreNode(this.service, this.nativeInstance);

  @override
  CollectionReference collection(String path) =>
      _collectionReference(this, nativeInstance.collection(path));

  @override
  DocumentReference doc(String path) =>
      _wrapDocumentReference(this, nativeInstance.doc(path));

  @override
  WriteBatch batch() => WriteBatchNode(nativeInstance.batch());

  @override
  Future<T> runTransaction<T>(
      FutureOr<T> Function(Transaction transaction) updateFunction) async {
    late T result;
    await nativeInstance.runTransaction((nativeTransaction) {
      return () async {
        var transaction = TransactionNode(this, nativeTransaction);
        var resultOrFuture = updateFunction(transaction);
        if (resultOrFuture is Future) {
          result = (await resultOrFuture);
        } else {
          result = resultOrFuture;
        }
      }()
          .toJS;
    }).toDart;
    return result;
  }

  @override
  void settings(FirestoreSettings settings) {
    nativeInstance.settings(_unwrapSettings(settings));
  }

  @override
  Future<List<DocumentSnapshot>> getAll(List<DocumentReference> refs) async {
    var jsRefs = _unwrapDocumentReferences(refs);
    late js.JSPromise<js.JSArray<node.DocumentSnapshot>> result;
    if (jsRefs.length == 1) {
      result = nativeInstance.getAll(jsRefs[0]);
    } else if (jsRefs.length == 2) {
      result = nativeInstance.getAll(jsRefs[0], jsRefs[1]);
    } else if (jsRefs.length == 3) {
      result = nativeInstance.getAll(jsRefs[0], jsRefs[1], jsRefs[2]);
    } else if (jsRefs.length == 4) {
      result =
          nativeInstance.getAll(jsRefs[0], jsRefs[1], jsRefs[2], jsRefs[3]);
    } else if (jsRefs.length == 5) {
      result = nativeInstance.getAll(
          jsRefs[0], jsRefs[1], jsRefs[2], jsRefs[3], jsRefs[4]);
    } else {
      throw ArgumentError('Unsupported getAll with ${jsRefs.length} refs');
    }
    return _wrapDocumentSnapshots(this, (await result.toDart).toDart);
  }

  @override
  Future<List<CollectionReference>> listCollections() async {
    return (await (nativeInstance.listCollections().toDart))
        .toDart
        .map((e) => _collectionReference(this, e))
        .toList();
  }

  @override
  String toString() => 'FirestoreNode()';
}

//FirestoreNode firestore(node.Firestore impl) => FirestoreNode(impl);

CollectionReferenceNode _collectionReference(
        Firestore firestore, node.CollectionReference impl) =>
    CollectionReferenceNode._(firestore, impl);

DocumentReferenceNode _wrapDocumentReference(
        Firestore firestore, node.DocumentReference impl) =>
    DocumentReferenceNode._(firestore, impl);

DocumentReferenceNode? _wrapDocumentReferenceOrNull(
        Firestore firestore, node.DocumentReference? impl) =>
    impl == null ? null : _wrapDocumentReference(firestore, impl);

node.DocumentReference _unwrapDocumentReference(DocumentReference docRef) =>
    (docRef as DocumentReferenceNode).nativeInstance;

List<node.DocumentReference> _unwrapDocumentReferences(
        Iterable<DocumentReference> docRef) =>
    docRef.map((ref) => _unwrapDocumentReference(ref)!).toList(growable: false);

class WriteBatchNode implements WriteBatch {
  final node.WriteBatch nativeInstance;

  WriteBatchNode(this.nativeInstance);

  @override
  Future commit() => nativeInstance.commit().toDart;

  @override
  void delete(DocumentReference ref) =>
      nativeInstance.delete(_unwrapDocumentReference(ref));

  @override
  void set(DocumentReference ref, Map<String, dynamic> data,
      [SetOptions? options]) {
    final docData = documentDataToNativeDocumentData(DocumentData(data));
    final nativeRef = _unwrapDocumentReference(ref);
    if (options != null) {
      nativeInstance.set(nativeRef, docData, _unwrapSetOptions(options));
    } else {
      nativeInstance.set(nativeRef, docData);
    }
  }

  @override
  void update(DocumentReference ref, Map<String, dynamic> data) =>
      nativeInstance.update(_unwrapDocumentReference(ref),
          documentDataToNativeUpdateData(DocumentData(data)));
}

class QueryNode extends Object
    with QueryDefaultMixin, FirestoreQueryExecutorMixin, QueryNodeMixin {
  @override
  final Firestore firestore;
  @override
  final node.DocumentQuery nativeInstance;

  QueryNode(this.firestore, this.nativeInstance);
}

const orderByDirectionAsc = 'asc';
const orderByDirectionDesc = 'desc';

abstract mixin class QueryNodeMixin implements Query {
  node.DocumentQuery get nativeInstance;

  @override
  Future<QuerySnapshot> get() async =>
      _wrapQuerySnapshot(firestore, await nativeInstance.get().toDart);

  @override
  Query select(List<String> fieldPaths) =>
      _wrapQuery(firestore, nativeInstance.select(fieldPaths));

  @override
  Query limit(int limit) => _wrapQuery(firestore, nativeInstance.limit(limit));

  @override
  Query orderBy(String key, {bool? descending}) {
    // if (key == firestoreNameFieldPath) {
    return _wrapQuery(
        firestore,
        nativeInstance.orderBy(key,
            (descending ?? false) ? orderByDescending : orderByDirectionAsc));
  }

  @override
  QueryNode startAt({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.startAt(unwrapValues(values));
    } else {
      result = nativeInstance
          .startAtDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestore, result);
  }

  @override
  Query startAfter({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.startAfter(unwrapValues(values));
    } else {
      result = nativeInstance
          .startAfterDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestore, result);
  }

  @override
  QueryNode endAt({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.endAt(unwrapValues(values));
    } else {
      result = nativeInstance
          .endAtDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestore, result);
  }

  @override
  QueryNode endBefore({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.endBefore(unwrapValues(values));
    } else {
      result = nativeInstance
          .endBeforeDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestore, result);
  }

  @override
  QueryNode where(
    String field, {
    Object? isEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object>? arrayContainsAny,
    List<Object>? whereIn,
    List<Object>? notIn,
    bool? isNull,
  }) {
    var query = nativeInstance;

    void addCondition(String field, String opStr, Object value) {
      query = query.where(field, opStr, unwrapValue(value));
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);
    if (isLessThan != null) addCondition(field, '<', isLessThan);
    if (isLessThanOrEqualTo != null) {
      addCondition(field, '<=', isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) addCondition(field, '>', isGreaterThan);
    if (isGreaterThanOrEqualTo != null) {
      addCondition(field, '>=', isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      addCondition(field, 'array-contains', arrayContains);
    }
    if (whereIn != null) {
      addCondition(field, 'in', whereIn);
    }
    if (notIn != null) {
      addCondition(field, 'not-in', notIn);
    }
    if (arrayContainsAny != null) {
      addCondition(field, 'array-contains-any', arrayContainsAny);
    }

    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      query = query.where(field, '==', null);
    }
    return _wrapQuery(firestore, query);
  }

  @override
  Stream<QuerySnapshot> onSnapshot({bool includeMetadataChanges = false}) {
    late StreamController<QuerySnapshot> streamController;
    void onNext(node.QuerySnapshot nativeQuerySnapshot) {
      streamController.add(_wrapQuerySnapshot(firestore, nativeQuerySnapshot));
    }

    void onError(js.JSAny error) {
      streamController.addError(FirestoreErrorNode(error));
    }

    late js.JSFunction? unsubscribe;
    streamController = StreamController<QuerySnapshot>(
        sync: true,
        onListen: () {
          unsubscribe = nativeInstance.onSnapshot(onNext.toJS, onError.toJS);
        },
        onCancel: () {
          unsubscribe?.callAsFunction();
        });

    //return nativeInstance.onSnapshot(onNext.toJS).transform(transformer);
    return streamController.stream;
  }

  @override
  Future<int> count() async {
    return ((await nativeInstance.count().get().toDart) as js.JSNumber)
        .toDartInt;
  }

  @override
  AggregateQuery aggregate(List<AggregateField> aggregateFields) {
    return AggregateQueryNode(this, aggregateFields);
  }
}

class CollectionReferenceNode extends QueryNode implements CollectionReference {
  @override
  node.CollectionReference get nativeInstance =>
      super.nativeInstance as node.CollectionReference;

  CollectionReferenceNode._(
      super.firestore, node.CollectionReference super.implCollectionReference);

  @override
  DocumentReference doc([String? path]) =>
      _wrapDocumentReference(firestore, nativeInstance.doc(path));

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async =>
      _wrapDocumentReference(
          firestore,
          (await nativeInstance
              .add(documentDataToNativeDocumentData(DocumentData(data)))
              .toDart));

  @override
  // ignore: invalid_use_of_protected_member
  String get id => nativeInstance.id;

  @override
  DocumentReference? get parent =>
      _wrapDocumentReferenceOrNull(firestore, nativeInstance.parent);

  @override
  // ignore: invalid_use_of_protected_member
  String get path => nativeInstance.path;

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
List<js.JSAny?> unwrapValues(List values) =>
    values.map(unwrapValueOrNull).toList(growable: false);

js.JSAny unwrapValue(Object value) {
  if (value is num) {
    return value.toJS;
  } else if (value is bool) {
    return value.toJS;
  } else if (value is DateTime) {
    return value.toJS;
  } else if (value is Timestamp) {
    return node.Timestamp(value.seconds, value.nanoseconds);
  } else if (value is Map) {
    var object = js.JSObject();
    value.forEach((key, value) {
      object.setProperty((key as String).toJS, unwrapValueOrNull(value));
    });
    return object;
  } else if (value is List) {
    return value.map(unwrapValueOrNull).toList().toJS;
  } else {
    throw ArgumentError.value(
        value, '${value.runtimeType}', 'Unsupported value for _unwrapValue');
  }
}

js.JSAny? unwrapValueOrNull(Object? value) {
  if (value == null) {
    return null;
  } else {
    return unwrapValue(value);
  }
}

/*
js.Timestamp _createJsTimestamp(Timestamp ts) {
  return js.callConstructor(
      firebaseNode.nativeInstance.admin.firestore.Timestamp, jsify([ts.seconds, ts.nanoseconds]) as List) as js.Timestamp;
}
*/

List listToNative(Iterable list) {
  return list.map((value) => documentValueToNativeValueOrNull(value)).toList();
}

class FirestoreErrorNode implements Exception {
  final js.JSAny error;

  FirestoreErrorNode(this.error);

  String get message => error.toString();
}

js.JSAny documentValueToNativeValue(Object value) {
  if (value is FieldValue) {
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
    throw ArgumentError('Unsupported FieldValue $value');
  } else if (value is DocumentReferenceNode) {
    return value.nativeInstance;
    /*
  } else if (value is GeoPoint) {
    return node.GeoPoint(value.latitude.toDouble(), value.longitude.toDouble());
  } else if (value is Blob) {
    return node.Blob.fromUint8List(value.data);*/
  } else {
    return unwrapValue(value);
  }
}

js.JSAny? documentValueToNativeValueOrNull(js.JSAny? value) {
  if (value == null) {
    return null;
  }
  return documentValueToNativeValue(value);
}

Object documentValueFromNativeValue(Firestore firestore, js.JSAny value) {
  if (value is js.JSNumber) {
    return value.toDartNum;
  } else if (value is js.JSBoolean) {
    return value.toDart;
  } else if (value is js.JSString) {
    return value.toDart;
  } else if (value is js.JSDate) {
    return value.toDart;
  } else if (value is node.Timestamp) {
    return Timestamp(value.seconds, value.nanoseconds);
  } else if (value == node.Firestore.fieldValues.delete()) {
    return FieldValue.delete;
  } else if (value == node.Firestore.fieldValues.serverTimestamp()) {
    return FieldValue.serverTimestamp;
  } else if (value is List) {
    return value
        .map((value) => documentValueFromNativeValueOrNull(firestore, value))
        .toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) => MapEntry(
        key as String, documentValueFromNativeValueOrNull(firestore, value)));
  } else if (value is node.GeoPoint) {
    return GeoPoint(value.latitude, value.longitude);
  } else if (value is node.Blob) {
    return Blob(value.asUint8List());
  } else if (value is node.DocumentReference) {
    return DocumentReferenceNode._(firestore, value);
  } else {
    throw ArgumentError.value(value, '${value.runtimeType}',
        'Unsupported value for documentValueFromNativeValue');
  }
}

Object? documentValueFromNativeValueOrNull(Firestore firestore, Object? value) {
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
    return value
        .map((value) => documentValueFromNativeValueOrNull(firestore, value))
        .toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) => MapEntry(
        key as String, documentValueFromNativeValueOrNull(firestore, value)));
  } else if (value is node.GeoPoint) {
    return GeoPoint(value.latitude, value.longitude);
  } else if (value is node.Blob) {
    return Blob(value.asUint8List());
  } else if (value is node.DocumentReference) {
    return DocumentReferenceNode._(firestore, value);
  } else {
    throw ArgumentError.value(value, '${value.runtimeType}',
        'Unsupported value for documentValueFromNativeValue');
  }
}

node.DocumentData documentDataToNativeDocumentData(DocumentData documentData) {
  var map = (documentData as DocumentDataMap).map;
  var nativeMap = documentValueToNativeValueOrNull(map) as Map<String, dynamic>;
  final nativeInstance = node.DocumentData.fromMap(nativeMap);
  return nativeInstance;
}

DocumentData documentDataFromNativeDocumentData(
    Firestore firestore, node.DocumentData nativeInstance) {
  var nativeMap = nativeInstance.toMap();
  var map = documentValueFromNativeValueOrNull(firestore, nativeMap)
      as Map<String, dynamic>;
  var documentData = DocumentData(map);
  return documentData;
}

node.UpdateData documentDataToNativeUpdateData(DocumentData documentData) {
  var map = (documentData as DocumentDataMap).map;
  var nativeMap = documentValueToNativeValueOrNull(map) as Map<String, dynamic>;
  final nativeInstance = node.UpdateData.fromMap(nativeMap);
  return nativeInstance;
}

class DocumentReferenceNode
    with DocumentReferenceDefaultMixin
    implements DocumentReference {
  @override
  final Firestore firestore;
  final node.DocumentReference nativeInstance;

  DocumentReferenceNode._(this.firestore, this.nativeInstance);

  @override
  CollectionReference collection(path) =>
      _collectionReference(firestore, nativeInstance.collection(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions? options]) async {
    await nativeInstance.setData(
        documentDataToNativeDocumentData(DocumentData(data)),
        _unwrapSetOptions(options));
  }

  @override
  Future<DocumentSnapshot> get() async =>
      _wrapDocumentSnapshot(firestore, await nativeInstance.get().toDart);

  @override
  Future delete() async {
    await nativeInstance.delete().toDart;
  }

  @override
  Future update(Map<String, dynamic> data) async {
    await nativeInstance
        .update(documentDataToNativeUpdateData(DocumentData(data)))
        .toDart;
  }

  @override
  String get id => nativeInstance.id;

  @override
  CollectionReference get parent =>
      _collectionReference(firestore, nativeInstance.parent);

  @override
  String get path => nativeInstance.path;

  @override
  Stream<DocumentSnapshot> onSnapshot({bool includeMetadataChanges = false}) {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (node.DocumentSnapshot nativeDocumentSnapshot,
            EventSink<DocumentSnapshot> sink) {
      sink.add(_wrapDocumentSnapshot(firestore, nativeDocumentSnapshot));
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

  @override
  Future<List<CollectionReference>> listCollections() async {
    return (await nativeInstance.listCollections().toDart)
        .toDart
        .map((e) => _collectionReference(firestore, e))
        .toList();
  }
}

class DocumentSnapshotNode
    with DocumentSnapshotMixin
    implements DocumentSnapshot {
  final Firestore firestore;
  final node.DocumentSnapshot nativeInstance;

  DocumentSnapshotNode(this.firestore, this.nativeInstance);

  @override
  Map<String, dynamic> get data => (exists
      ? documentDataFromNativeDocumentData(firestore, nativeInstance.data()!)
          .asMap()
      : null)!;

  @override
  DocumentReference get ref =>
      _wrapDocumentReference(firestore, nativeInstance.ref);

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
  final Firestore firestore;
  final node.DocumentChange nativeInstance;

  DocumentChangeNode(this.firestore, this.nativeInstance);

  @override
  DocumentSnapshot get document =>
      _wrapDocumentSnapshot(firestore, nativeInstance.document);

  @override
  int get newIndex => nativeInstance.newIndex;

  @override
  int get oldIndex => nativeInstance.oldIndex;

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type!);
}

class QuerySnapshotNode implements QuerySnapshot {
  final Firestore firestore;
  final node.QuerySnapshot nativeInstance;

  QuerySnapshotNode._(this.firestore, this.nativeInstance);

  @override
  List<DocumentSnapshot> get docs {
    var implDocs = nativeInstance.documents;
    if (implDocs == null) {
      return <DocumentSnapshot>[];
    }
    var docs = <DocumentSnapshot?>[];
    for (var implDocumentSnapshot in implDocs) {
      docs.add(_wrapDocumentSnapshot(firestore, implDocumentSnapshot));
    }
    return docs.cast<DocumentSnapshot>();
  }

  @override
  List<DocumentChange> get documentChanges {
    var changes = <DocumentChange>[];
    if (nativeInstance.documentChanges != null) {
      for (var nativeChange in nativeInstance.documentChanges!) {
        changes.add(DocumentChangeNode(firestore, nativeChange));
      }
    }
    return changes;
  }
}

class TransactionNode implements Transaction {
  final Firestore firestore;
  final node.Transaction nativeInstance;

  TransactionNode(this.firestore, this.nativeInstance);

  @override
  void delete(DocumentReference documentRef) {
    nativeInstance.delete(_unwrapDocumentReference(documentRef)!);
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) async =>
      _wrapDocumentSnapshot(firestore,
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

QueryNode _wrapQuery(Firestore firestore, node.DocumentQuery nativeInstance) =>
    QueryNode(firestore, nativeInstance);

DocumentSnapshotNode _wrapDocumentSnapshot(
        Firestore firestore, node.DocumentSnapshot nativeInstance) =>
    DocumentSnapshotNode(firestore, nativeInstance);

List<DocumentSnapshotNode> _wrapDocumentSnapshots(
        Firestore firestore, Iterable<node.DocumentSnapshot> nativeInstances) =>
    nativeInstances
        .map((e) => _wrapDocumentSnapshot(firestore, e))
        .toList(growable: false);

node.DocumentSnapshot _unwrapDocumentSnapshot(DocumentSnapshot snapshot) =>
    (snapshot as DocumentSnapshotNode).nativeInstance;

node.DocumentSnapshot? _unwrapDocumentSnapshotOrNull(
        DocumentSnapshot? snapshot) =>
    snapshot != null ? _unwrapDocumentSnapshot(snapshot) : null;

QuerySnapshotNode _wrapQuerySnapshot(
        Firestore firestore, node.QuerySnapshot nativeInstance) =>
    QuerySnapshotNode._(firestore, nativeInstance);

node.SetOptions? _unwrapSetOptions(SetOptions? options) =>
    options != null ? node.SetOptions(merge: options.merge == true) : null;

String indexAlias(int index) => 'field_$index';

int aliasIndex(String alias) => int.parse(alias.substring('field_'.length));

class AggregateQueryNode implements AggregateQuery {
  final QueryNodeMixin queryNode;
  final List<AggregateField> aggregateFields;

  AggregateQueryNode(this.queryNode, this.aggregateFields);

  node.AggregateField toNodeAggregateField(
      int index, AggregateField aggregateField) {
    if (aggregateField is AggregateFieldCount) {
      return node.AggregateFieldCount();
    } else if (aggregateField is AggregateFieldAverage) {
      return node.AggregateFieldAverage(
          indexAlias(index), aggregateField.field);
    } else if (aggregateField is AggregateFieldSum) {
      return node.AggregateFieldSum(indexAlias(index), aggregateField.field);
    } else {
      throw ArgumentError('Unsupported aggregateField $aggregateField');
    }
  }

  @override
  Future<AggregateQuerySnapshot> get() async {
    var nativeAggregateQuery = queryNode.nativeInstance.aggregate(
        aggregateFields.indexed
            .map((e) => toNodeAggregateField(e.$1, e.$2))
            .toList(growable: false));
    var nativeQuerySnapshot = await nativeAggregateQuery.get();
    return AggregateQuerySnapshotNode(this, nativeQuerySnapshot);
  }
}

class AggregateQuerySnapshotNode implements AggregateQuerySnapshot {
  final AggregateQueryNode aggregateQueryNode;
  final node.AggregateQuerySnapshot nativeInstance;

  AggregateQuerySnapshotNode(this.aggregateQueryNode, this.nativeInstance);

  @override
  int? get count => nativeInstance.count;

  @override
  double? getAverage(String fieldPath) {
    for (var e in aggregateQueryNode.aggregateFields.indexed) {
      var aggregateField = e.$2;
      if (aggregateField is AggregateFieldAverage &&
          aggregateField.field == fieldPath) {
        var index = e.$1;
        return nativeInstance.getAlias(indexAlias(index))?.toDouble();
      }
    }
    return null;
  }

  @override
  double? getSum(String fieldPath) {
    for (var e in aggregateQueryNode.aggregateFields.indexed) {
      var aggregateField = e.$2;
      if (aggregateField is AggregateFieldSum &&
          aggregateField.field == fieldPath) {
        var index = e.$1;
        return nativeInstance.getAlias(indexAlias(index))?.toDouble();
      }
    }
    return null;
  }

  @override
  Query get query => aggregateQueryNode.queryNode;
}
*/
