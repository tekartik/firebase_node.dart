library;

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_firestore_node/src/import_firestore.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase_node/impl/firebase_node.dart' show AppNode;
import 'package:tekartik_js_utils_interop/js_date.dart' as js;
import 'package:tekartik_js_utils_interop/js_number.dart' as js;
import 'package:tekartik_js_utils_interop/object_keys.dart' as js;

import 'common_import.dart';
import 'firestore_node_js_interop.dart' as js;
import 'firestore_node_js_interop.dart' as node;

node.FirestoreSettings _unwrapSettings(FirestoreSettings settings) {
  var nativeSettings = node.FirestoreSettings(
      // ignore: deprecated_member_use
      timestampsInSnapshots: settings.timestampsInSnapshots);
  return nativeSettings;
}

class FirestoreServiceNode
    with
        FirebaseProductServiceMixin<Firestore>,
        FirestoreServiceDefaultMixin,
        FirestoreServiceMixin
    implements FirestoreService {
  @override
  Firestore firestore(App app) {
    return getInstance(app, () {
      assert(app is AppNode, 'invalid firebase app type');
      final appNode = app as AppNode;
      return FirestoreNode(
          this,
          appNode,
          node.firebaseAdminFirestoreModule
              .getFirestore(appNode.nativeInstance));
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

class FirestoreNode
    with FirebaseAppProductMixin<Firestore>, FirestoreDefaultMixin
    implements Firestore {
  final AppNode appNode;
  @override
  final FirestoreServiceNode service;
  final node.Firestore nativeInstance;

  FirestoreNode(this.service, this.appNode, this.nativeInstance);

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
    await nativeInstance
        .runTransaction((node.Transaction nativeTransaction) {
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
        }.toJS)
        .toDart;
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

  @override
  FirebaseApp get app => appNode;
}

//FirestoreNode firestore(node.Firestore impl) => FirestoreNode(impl);

CollectionReferenceNode _collectionReference(
        FirestoreNode firestore, node.CollectionReference impl) =>
    CollectionReferenceNode._(firestore, impl);

DocumentReferenceNode _wrapDocumentReference(
        FirestoreNode firestore, node.DocumentReference impl) =>
    DocumentReferenceNode._(firestore, impl);

DocumentReferenceNode? _wrapDocumentReferenceOrNull(
        FirestoreNode firestore, node.DocumentReference? impl) =>
    impl == null ? null : _wrapDocumentReference(firestore, impl);

node.DocumentReference _unwrapDocumentReference(DocumentReference docRef) =>
    (docRef as DocumentReferenceNode).nativeInstance;

List<node.DocumentReference> _unwrapDocumentReferences(
        Iterable<DocumentReference> docRef) =>
    docRef.map((ref) => _unwrapDocumentReference(ref)).toList(growable: false);

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
  final FirestoreNode firestore;
  @override
  final node.DocumentQuery nativeInstance;

  QueryNode(this.firestore, this.nativeInstance);
}

const orderByDirectionAsc = 'asc';
const orderByDirectionDesc = 'desc';

abstract mixin class QueryNodeMixin implements Query {
  FirestoreNode get firestoreNode => firestore as FirestoreNode;

  node.DocumentQuery get nativeInstance;

  @override
  Future<QuerySnapshot> get() async =>
      _wrapQuerySnapshot(firestoreNode, await nativeInstance.get().toDart);

  @override
  Query select(List<String> fieldPaths) =>
      _wrapQuery(firestoreNode, nativeInstance.selectAll(fieldPaths));

  @override
  Query limit(int limit) =>
      _wrapQuery(firestoreNode, nativeInstance.limit(limit));

  @override
  Query orderBy(String key, {bool? descending}) {
    // if (key == firestoreNameFieldPath) {
    return _wrapQuery(
        firestoreNode,
        nativeInstance.orderBy(key,
            (descending ?? false) ? orderByDescending : orderByDirectionAsc));
  }

  @override
  QueryNode startAt({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.startAt(toNativeValues(values));
    } else {
      result = nativeInstance
          .startAtDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestoreNode, result);
  }

  @override
  Query startAfter({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.startAfter(toNativeValues(values));
    } else {
      result = nativeInstance
          .startAfterDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestoreNode, result);
  }

  @override
  QueryNode endAt({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.endAt(toNativeValues(values));
    } else {
      result = nativeInstance
          .endAtDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestoreNode, result);
  }

  @override
  QueryNode endBefore({DocumentSnapshot? snapshot, List? values}) {
    node.DocumentQuery result;
    if (values != null) {
      assert(snapshot == null);
      result = nativeInstance.endBefore(toNativeValues(values));
    } else {
      result = nativeInstance
          .endBeforeDocumentSnapshot(_unwrapDocumentSnapshot(snapshot!));
    }
    return _wrapQuery(firestoreNode, result);
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
      query = query.where(field, opStr, toNativeValue(value));
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
    return _wrapQuery(firestoreNode, query);
  }

  @override
  Stream<QuerySnapshot> onSnapshot({bool includeMetadataChanges = false}) {
    late StreamController<QuerySnapshot> streamController;
    void onNext(node.QuerySnapshot nativeQuerySnapshot) {
      streamController
          .add(_wrapQuerySnapshot(firestoreNode, nativeQuerySnapshot));
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
    return ((await nativeInstance.count().get().toDart)
            .data()
            .getProperty('count'.toJS) as js.JSNumber)
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
List<js.JSAny?> toNativeValues(List values) =>
    values.map(toNativeValueOrNull).toList(growable: false);

js.JSAny toNativeValue(Object value,
    [js.JSAny? Function(Object?)? nestedToNativeValueOrNull]) {
  var nativeValue = commonToNativeValue(value, nestedToNativeValueOrNull);
  if (nativeValue == null) {
    throw ArgumentError.value(
        value, '${value.runtimeType}', 'Unsupported value for toNativeValue');
  }
  return nativeValue;
}

js.JSAny? commonToNativeValue(Object value,
    [js.JSAny? Function(Object?)? nestedToNativeValueOrNull]) {
  if (value is String) {
    return value.toJS;
  } else if (value is num) {
    return value.toJS;
  } else if (value is bool) {
    return value.toJS;
  } else if (value is DateTime) {
    return value.toJS;
  } else if (value is Timestamp) {
    return node.firestoreModule.timestampProto
        .fromSecondsAndNanoseconds(value.seconds, value.nanoseconds);
  } else if (value is Map) {
    var object = js.JSObject();
    value.forEach((key, value) {
      object.setProperty((key as String).toJS,
          (nestedToNativeValueOrNull ?? toNativeValueOrNull)(value));
    });
    return object;
  } else if (value is List) {
    return value
        .map(nestedToNativeValueOrNull ?? toNativeValueOrNull)
        .toList()
        .toJS;
  } else if (value is Blob) {
    return value.data.toJS;
  } else if (value is GeoPoint) {
    return node.firestoreModule.geoPointProto
        .fromLatitudeAndLongitude(value.latitude, value.longitude);
  } else if (value is DocumentReferenceNode) {
    return value.nativeInstance;
  }
  return null;
}

js.JSAny? toNativeValueOrNull(Object? value,
    [js.JSAny? Function(Object?)? nestedToNativeValueOrNull]) {
  if (value == null) {
    return null;
  } else {
    return toNativeValue(value, nestedToNativeValueOrNull);
  }
}

/*
js.Timestamp _createJsTimestamp(Timestamp ts) {
  return js.callConstructor(
      firebaseNode.nativeInstance.admin.firestore.Timestamp, jsify([ts.seconds, ts.nanoseconds]) as List) as js.Timestamp;
}
*/

js.JSArray<js.JSAny> listToNative(Iterable<Object?> list) {
  return list.map((value) => documentValueToNativeValue(value!)).toList().toJS;
}

List<js.JSAny?> listToNativeOrNull(Iterable<Object?> list) {
  return list.map((value) => documentValueToNativeValueOrNull(value)).toList();
}

class FirestoreErrorNode implements Exception {
  final js.JSAny error;

  FirestoreErrorNode(this.error);

  String get message => error.toString();
}

js.JSAny documentValueToNativeValue(Object value) {
  var nativeValue = commonToNativeValue(
      value, (value) => documentValueToNativeValueOrNull(value));
  if (nativeValue == null) {
    if (value is FieldValue) {
      if (value == FieldValue.delete) {
        return node.firestoreModule.fieldValue.delete();
      } else if (value == FieldValue.serverTimestamp) {
        return node.firestoreModule.fieldValue.serverTimestamp();
      } else if (value is FieldValueArray) {
        if (value.type == FieldValueType.arrayUnion) {
          return node.firestoreModule.fieldValue.arrayUnion(value.data
              .map((element) => toNativeValueOrNull(element))
              .toList());
        } else if (value.type == FieldValueType.arrayRemove) {
          return node.firestoreModule.fieldValue.arrayRemove(value.data
              .map((element) => toNativeValueOrNull(element))
              .toList());
        }
      }
      throw ArgumentError('Unsupported FieldValue $value');
    }
    throw ArgumentError.value(value, '${value.runtimeType}',
        'Unsupported value for documentValueToNativeValue');
  }
  return nativeValue;
}

js.JSAny? documentValueToNativeValueOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return documentValueToNativeValue(value);
}

Object fromNativeValue(js.JSAny value,
    [Object? Function(js.JSAny? value)? nestedFromNativeValueOrNull]) {
  var dartValue = _commonSimpleTypesFromNativeValue(value);
  if (dartValue != null) {
    return dartValue;
  }
  try {
    value = value as js.JSObject;
    return fromNativeMap(value, nestedFromNativeValueOrNull);
  } catch (_) {}

  throw ArgumentError.value(
      value, '${value.runtimeType}', 'Unsupported value for fromNativeValue');
}

/// All but map
Object? _commonSimpleTypesFromNativeValue(js.JSAny value,
    [Object? Function(js.JSAny? value)? nestedFromNativeValueOrNull]) {
  if (value.isA<js.JSNumber>()) {
    return (value as js.JSNumber).toDartNum;
  } else if (value.isA<js.JSBoolean>()) {
    return (value as js.JSBoolean).toDart;
  } else if (value.isA<js.JSString>()) {
    return (value as js.JSString).toDart;
  } else if (value.isA<js.JSUint8Array>()) {
    return Blob((value as js.JSUint8Array).toDart);
  }
  if (value.isA<js.JSArray>()) {
    return fromNativeList((value as js.JSArray), nestedFromNativeValueOrNull);
  }
  js.JSObject jsObject;
  try {
    jsObject = value as js.JSObject;
  } catch (_) {
    return null;
  }

  if (jsObject.isJSTimestamp()) {
    var nodeTimestamp = value as node.Timestamp;
    return Timestamp(nodeTimestamp.seconds, nodeTimestamp.nanoseconds);
  } else if (value.isA<js.JSDate>()) {
    return (value as js.JSDate).toDart;
  } else if (value.isJSGeoPoint()) {
    var nodeGeoPoint = value as node.GeoPoint;
    return GeoPoint(nodeGeoPoint.latitude, nodeGeoPoint.longitude);
  }

  return null;
}

List fromNativeList(js.JSArray value,
    [Object? Function(js.JSAny? value)? nestedFromNativeValueOrNull]) {
  return value.toDart
      .map((value) =>
          (nestedFromNativeValueOrNull ?? fromNativeValueOrNull)(value))
      .toList();
}

Map<String, Object?> fromNativeMap(js.JSObject value,
    [Object? Function(js.JSAny? value)? nestedFromNativeValueOrNull]) {
  var map = <String, Object?>{};
  for (var key in js.jsObjectKeys(value)) {
    map[key] = (nestedFromNativeValueOrNull ??
        fromNativeValueOrNull)(value.getProperty(key.toJS));
  }
  return map;
}

Object? commonFromNativeValue(js.JSAny value,
    [Object? Function(js.JSAny? value)? nestedFromNativeValueOrNull]) {
  var dartValue = _commonSimpleTypesFromNativeValue(value);
  if (dartValue != null) {
    return dartValue;
  }
  try {
    value = value as js.JSObject;
    return fromNativeMap(value, nestedFromNativeValueOrNull);
  } catch (_) {}
  return null;
}

Object? fromNativeValueOrNull(js.JSAny? value) {
  if (value == null) {
    return null;
  }
  return fromNativeValue(value);
}

Object documentValueFromNativeValue(FirestoreNode firestore, js.JSAny value) {
  var dartValue = _commonSimpleTypesFromNativeValue(value);
  if (dartValue != null) {
    return dartValue;
  }
  try {
    value = value as js.JSObject;

    if (value.isJSDocumentReference()) {
      return DocumentReferenceNode._(
          firestore, value as node.DocumentReference);
    }
    if (value == node.firestoreModule.fieldValue.delete()) {
      return FieldValue.delete;
    } else if (value == node.firestoreModule.fieldValue.serverTimestamp()) {
      return FieldValue.serverTimestamp;
    }
    return fromNativeMap(
        value, (value) => documentValueFromNativeValueOrNull(firestore, value));
  } catch (_) {}
  throw ArgumentError.value(value, '${value.runtimeType}',
      'Unsupported value for documentValueFromNativeValue');
}

Object? documentValueFromNativeValueOrNull(
    FirestoreNode firestore, js.JSAny? value) {
  if (value == null) {
    return null;
  }
  return documentValueFromNativeValue(firestore, value);
}

node.DocumentData documentDataToNativeDocumentData(DocumentData documentData) {
  var map = (documentData as DocumentDataMap).map;
  var nativeMap = documentValueToNativeValueOrNull(map);
  return nativeMap as node.DocumentData;
}

DocumentData documentDataFromNativeDocumentData(
    FirestoreNode firestore, node.DocumentData nativeInstance) {
  var map = documentValueFromNativeValueOrNull(firestore, nativeInstance)
      as Map<String, dynamic>;
  var documentData = DocumentData(map);
  return documentData;
}

node.UpdateData documentDataToNativeUpdateData(DocumentData documentData) {
  var map = (documentData as DocumentDataMap).map;
  var nativeMap = documentValueToNativeValueOrNull(map);
  return nativeMap as node.UpdateData;
}

class DocumentReferenceNode
    with DocumentReferenceDefaultMixin
    implements DocumentReference {
  @override
  final FirestoreNode firestore;
  final node.DocumentReference nativeInstance;

  DocumentReferenceNode._(this.firestore, this.nativeInstance);

  @override
  CollectionReference collection(path) =>
      _collectionReference(firestore, nativeInstance.collection(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions? options]) async {
    await nativeInstance
        .set(documentDataToNativeDocumentData(DocumentData(data)),
            _unwrapSetOptions(options))
        .toDart;
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
    late StreamController<DocumentSnapshot> streamController;
    void onNext(node.DocumentSnapshot nativeDocumentSnapshot) {
      streamController
          .add(_wrapDocumentSnapshot(firestore, nativeDocumentSnapshot));
    }

    void onError(js.JSAny error) {
      streamController.addError(FirestoreErrorNode(error));
    }

    late js.JSFunction? unsubscribe;
    streamController = StreamController<DocumentSnapshot>(
        sync: true,
        onListen: () {
          unsubscribe = nativeInstance.onSnapshot(onNext.toJS, onError.toJS);
        },
        onCancel: () {
          unsubscribe?.callAsFunction();
        });

    return streamController.stream;
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
  final FirestoreNode firestore;
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

DocumentChangeType _wrapDocumentChangeType(String type) {
  switch (type) {
    case node.documentChangeTypeAdded:
      return DocumentChangeType.added;
    case node.documentChangeTypeRemoved:
      return DocumentChangeType.removed;
    case node.documentChangeTypeModified:
      return DocumentChangeType.modified;
  }
  throw UnsupportedError('Unsupported document change type "$type"');
}

class DocumentChangeNode implements DocumentChange {
  final FirestoreNode firestore;
  final node.DocumentChange nativeInstance;

  DocumentChangeNode(this.firestore, this.nativeInstance);

  @override
  DocumentSnapshot get document =>
      _wrapDocumentSnapshot(firestore, nativeInstance.doc);

  @override
  int get newIndex => nativeInstance.newIndex;

  @override
  int get oldIndex => nativeInstance.oldIndex;

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type);
}

class QuerySnapshotNode implements QuerySnapshot {
  final FirestoreNode firestore;
  final node.QuerySnapshot nativeInstance;

  QuerySnapshotNode._(this.firestore, this.nativeInstance);

  @override
  List<DocumentSnapshot> get docs {
    var implDocs = nativeInstance.docs;
    if (implDocs == null) {
      return <DocumentSnapshot>[];
    }
    return implDocs.toDart
        .map((element) => _wrapDocumentSnapshot(firestore, element))
        .toList();
  }

  @override
  List<DocumentChange> get documentChanges {
    return (nativeInstance
            .docChanges()
            ?.toDart
            .map((nativeChange) => DocumentChangeNode(firestore, nativeChange))
            .toList()) ??
        <DocumentChange>[];
  }
}

class TransactionNode implements Transaction {
  final FirestoreNode firestore;
  final node.Transaction nativeInstance;

  TransactionNode(this.firestore, this.nativeInstance);

  @override
  void delete(DocumentReference documentRef) {
    nativeInstance.delete(_unwrapDocumentReference(documentRef));
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) async =>
      _wrapDocumentSnapshot(
          firestore,
          await nativeInstance
              .get(_unwrapDocumentReference(documentRef))
              .toDart);

  @override
  void set(DocumentReference documentRef, Map<String, dynamic> data,
      [SetOptions? options]) {
    nativeInstance.set(
        _unwrapDocumentReference(documentRef),
        documentDataToNativeDocumentData(DocumentData(data)),
        _unwrapSetOptions(options));
  }

  @override
  void update(DocumentReference documentRef, Map<String, Object?> data) {
    nativeInstance.update(_unwrapDocumentReference(documentRef),
        documentDataToNativeUpdateData(DocumentData(data)));
  }
}

QueryNode _wrapQuery(
        FirestoreNode firestore, node.DocumentQuery nativeInstance) =>
    QueryNode(firestore, nativeInstance);

DocumentSnapshotNode _wrapDocumentSnapshot(
        FirestoreNode firestore, node.DocumentSnapshot nativeInstance) =>
    DocumentSnapshotNode(firestore, nativeInstance);

List<DocumentSnapshotNode> _wrapDocumentSnapshots(FirestoreNode firestore,
        Iterable<node.DocumentSnapshot> nativeInstances) =>
    nativeInstances
        .map((e) => _wrapDocumentSnapshot(firestore, e))
        .toList(growable: false);

node.DocumentSnapshot _unwrapDocumentSnapshot(DocumentSnapshot snapshot) =>
    (snapshot as DocumentSnapshotNode).nativeInstance;

QuerySnapshotNode _wrapQuerySnapshot(
        FirestoreNode firestore, node.QuerySnapshot nativeInstance) =>
    QuerySnapshotNode._(firestore, nativeInstance);

node.SetOptions? _unwrapSetOptions(SetOptions? options) =>
    options != null ? node.SetOptions(merge: options.merge == true) : null;

String indexAlias(int index) => 'field_$index';

int aliasIndex(String alias) => int.parse(alias.substring('field_'.length));

class AggregateQueryNode implements AggregateQuery {
  final QueryNodeMixin queryNode;
  final List<AggregateField> aggregateFields;

  AggregateQueryNode(this.queryNode, this.aggregateFields);

  node.AggregateField toNodeAggregateField(AggregateField aggregateField) {
    if (aggregateField is AggregateFieldCount) {
      return node.firestoreModule.aggregateFields.count();
    } else if (aggregateField is AggregateFieldAverage) {
      return node.firestoreModule.aggregateFields.average(aggregateField.field);
    } else if (aggregateField is AggregateFieldSum) {
      return node.firestoreModule.aggregateFields.sum(aggregateField.field);
    } else {
      throw ArgumentError('Unsupported aggregateField $aggregateField');
    }
  }

  @override
  Future<AggregateQuerySnapshot> get() async {
    var specs = node.AggregateSpecs();
    for (var (index, field) in aggregateFields.indexed) {
      specs.setProperty(indexAlias(index).toJS, toNodeAggregateField(field));
    }
    var nativeAggregateQuery = queryNode.nativeInstance.aggregate(specs);
    var nativeQuerySnapshot = await nativeAggregateQuery.get().toDart;
    return AggregateQuerySnapshotNode(this, nativeQuerySnapshot);
  }
}

class AggregateQuerySnapshotNode implements AggregateQuerySnapshot {
  final AggregateQueryNode aggregateQueryNode;
  final node.AggregateQuerySnapshot nativeInstance;

  AggregateQuerySnapshotNode(this.aggregateQueryNode, this.nativeInstance);

  js.JSNumber? _getProperty(int index) =>
      nativeInstance.data().getProperty(indexAlias(index).toJS) as js.JSNumber?;

  @override
  int? get count {
    for (var e in aggregateQueryNode.aggregateFields.indexed) {
      var aggregateField = e.$2;
      if (aggregateField is AggregateFieldCount) {
        var index = e.$1;
        return _getProperty(index)?.toDartInt;
      }
    }
    return null;
  }

  @override
  double? getAverage(String fieldPath) {
    for (var e in aggregateQueryNode.aggregateFields.indexed) {
      var aggregateField = e.$2;
      if (aggregateField is AggregateFieldAverage &&
          aggregateField.field == fieldPath) {
        var index = e.$1;
        return _getProperty(index)?.toDartDouble;
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
        return _getProperty(index)?.toDartDouble;
      }
    }
    return null;
  }

  @override
  Query get query => aggregateQueryNode.queryNode;
}
