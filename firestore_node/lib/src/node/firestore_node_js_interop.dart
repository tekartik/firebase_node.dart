library;

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

import 'package:tekartik_core_node/require.dart' as node;
// ignore: implementation_imports
import 'package:tekartik_firebase_node/src/node/firebase_node_js_interop.dart'
    as node;
import 'package:tekartik_js_utils_interop/js_date.dart' as js;

/// Singleton instance of [FirebaseAdmin] module.
final firebaseAdminFirestoreModule = () {
  return firestoreModule =
      node.require<FirestoreModule>('firebase-admin/firestore');
}();

final cloudFirestoreModule = () {
  return firestoreModule =
      node.require<FirestoreModule>('@google-cloud/firestore');
}();

/// First loaded wins
late FirestoreModule firestoreModule;
extension type FirestoreModule._(js.JSObject _) implements js.JSObject {}

extension FirestoreModuleExt on FirestoreModule {
  // ignore: non_constant_identifier_names
  @js.JS('FieldValue')
  external FieldValues get fieldValue;

  // ignore: non_constant_identifier_names
  @js.JS('Timestamp')
  external TimestampProto get timestampProto;

  @js.JS('GeoPoint')
  external GeoPointProto get geoPointProto;

  @js.JS('AggregateField')
  external AggregateFields get aggregateFields;

  /// Sets the log function for all active Firestore instances.
  external void setLogFunction(js.JSFunction logger);

  //void Function(String msg) logger);

  external Firestore getFirestore(node.App app);
}

extension type TimestampProto._(js.JSFunction _) implements js.JSFunction {}

extension TimestampProtoExt on TimestampProto {
  external Timestamp now();

  external Timestamp fromDate(js.JSDate date);

  external Timestamp fromMillis(int milliseconds);

  Timestamp fromSecondsAndNanoseconds(int seconds, int nanoseconds) {
    return (this as js.JSFunction)
        .callAsConstructorVarArgs([seconds.toJS, nanoseconds.toJS]);
  }
}

extension type Timestamp._(js.JSObject _) implements js.JSObject {
  //external Timestamp(int seconds, int nanoseconds);
}

extension TimestampExt on Timestamp {
  external int get seconds;

  external int get nanoseconds;

  external js.JSDate toDate();

  external int toMillis();
}

extension type BytesProto._(js.JSObject _) implements js.JSObject {}

/// An immutable object representing an array of bytes.
extension type Bytes._(js.JSObject _) implements js.JSObject {
  external Bytes fromUint8Array(js.JSUint8Array array);
}

extension BytesExt on Bytes {
  // Creates a new Bytes object from the given Uint8Array.
}

extension type GeoPointUtil._(js.JSObject _) implements js.JSObject {
  external GeoPoint fromProto(GeoPointUtil? proto);
}

extension type GeoPointProto._(js.JSFunction _) implements js.JSFunction {}

extension GeoPointProtoExt on GeoPointProto {
  external num get latitude;

  external num get longitude;

  GeoPoint fromLatitudeAndLongitude(num latitude, num longitude) {
    return callAsConstructorVarArgs([latitude.toJS, longitude.toJS]);
  }
}

extension type VectorValue._(js.JSObject _) implements js.JSObject {}

extension VectorValueExt on VectorValue {
  external js.JSArray toArray();

  List<double> toDoubleList() =>
      toArray().toDart.map((e) => (e as js.JSNumber).toDartDouble).toList();
}

/// Document data (for use with `DocumentReference.set()`) consists of fields
/// mapped to values.
extension type DocumentData._(js.JSObject _) implements js.JSObject {}

/// Update data (for use with `DocumentReference.update()`) consists of field
/// paths (e.g. 'foo' or 'foo.baz') mapped to values. Fields that contain dots
/// reference nested fields within the document.
extension type UpdateData._(js.JSObject _) implements js.JSObject {}

/// `Firestore` represents a Firestore Database and is the entry point for all
/// Firestore operations.
extension type Firestore._(js.JSObject _) implements js.JSObject {}

extension FirestoreExt on Firestore {
  /// Gets a `CollectionReference` instance that refers to the collection at
  /// the specified path.
  external CollectionReference collection(String collectionPath);

  /// Creates and returns a new Query that includes all documents in the
  /// database that are contained in a collection or subcollection with the
  /// given [collectionId].
  ///
  /// [collectionId] identifies the collections to query over. Every collection
  /// or subcollection with this ID as the last segment of its path will be
  /// included. Cannot contain a slash.
  external DocumentQuery collectionGroup(String collectionId);

  /// Gets a `DocumentReference` instance that refers to the document at the
  /// specified path.
  external DocumentReference doc(String documentPath);

  /// Retrieves multiple documents from Firestore.
  /// snapshots.
  external js.JSPromise<js.JSArray<DocumentSnapshot>> getAll(
      [DocumentReference? documentRef1,
      DocumentReference? documentRef2,
      DocumentReference? documentRef3,
      DocumentReference? documentRef4,
      DocumentReference? documentRef5]);

  /// Fetches the root collections that are associated with this Firestore
  /// database.
  external js.JSPromise<js.JSArray<CollectionReference>> listCollections();

  /// Executes the given updateFunction and commits the changes applied within
  /// the transaction.
  ///
  /// You can use the transaction object passed to [updateFunction] to read and
  /// modify Firestore documents under lock. Transactions are committed once
  /// [updateFunction] resolves and attempted up to five times on failure.
  ///
  ///
  /// If the transaction completed successfully or was explicitly aborted
  /// (by the [updateFunction] returning a failed Future), the Future
  /// returned by the updateFunction will be returned here. Else if the
  /// transaction failed, a rejected Future with the corresponding failure error
  /// will be returned.
  external js.JSPromise runTransaction(js.JSFunction updateFunction);

  //js.JSPromise Function(Transaction transaction) updateFunction);

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  external WriteBatch batch();

  /// Specifies custom settings to be used to configure the `Firestore`
  /// instance.
  ///
  /// Can only be invoked once and before any other [Firestore] method.
  external void settings(FirestoreSettings value);
}

extension type FirestoreSettings._(js.JSObject _) implements js.JSObject {
  external factory FirestoreSettings({
    String? projectId,
    String? keyFilename,
    bool? timestampsInSnapshots,
  });
}

extension FirestoreSettingsExt on FirestoreSettings {
  /// The Firestore Project ID.
  ///
  /// Can be omitted in environments that support `Application Default Credentials`.
  external String get projectId;

  /// Local file containing the Service Account credentials.
  ///
  /// Can be omitted in environments that support `Application Default Credentials`.
  external String get keyFilename;

  /// Enables the use of `Timestamp`s for timestamp fields in
  /// `DocumentSnapshot`s.
  ///
  /// Currently, Firestore returns timestamp fields as `Date` but `Date` only
  /// supports millisecond precision, which leads to truncation and causes
  /// unexpected behavior when using a timestamp from a snapshot as a part
  /// of a subsequent query.
  ///
  /// Setting `timestampsInSnapshots` to true will cause Firestore to return
  /// `Timestamp` values instead of `Date` avoiding this kind of problem. To
  /// make this work you must also change any code that uses `Date` to use
  /// `Timestamp` instead.
  ///
  /// NOTE: in the future `timestampsInSnapshots: true` will become the
  /// default and this option will be removed so you should change your code to
  /// use `Timestamp` now and opt-in to this new behavior as soon as you can.
  external bool get timestampsInSnapshots;
}

/// An immutable object representing a geo point in Firestore. The geo point
/// is represented as latitude/longitude pair.
/// Latitude values are in the range of [-90, 90].
/// Longitude values are in the range of [-180, 180].
extension type GeoPoint._(js.JSObject _) implements js.JSObject {}

extension GeoPointExt on GeoPoint {
  external num get latitude;

  external num get longitude;
}

/// A reference to a transaction.
/// The `Transaction` object passed to a transaction's updateFunction provides
/// the methods to read and write data within the transaction context. See
/// `Firestore.runTransaction()`.
extension type Transaction._(js.JSObject _) implements js.JSObject {}

extension TransactionExt on Transaction {
  /// Reads the document referenced by the provided `DocumentReference.`
  /// Holds a pessimistic lock on the returned document.
  /*external js.JSPromise<DocumentSnapshot> get(DocumentReference documentRef);*/

  /// Retrieves a query result. Holds a pessimistic lock on the returned
  /// documents.
  /*external js.JSPromise<QuerySnapshot> get(Query query);*/
  external js.JSPromise<
          DocumentSnapshot> /*Promise<DocumentSnapshot>|Promise<QuerySnapshot>*/
      get(DocumentReference documentRef);

  @js.JS('get')
  external js.JSPromise<
          DocumentSnapshot> /*Promise<DocumentSnapshot>|Promise<QuerySnapshot>*/
      queryGet(DocumentQuery documentRefQuery);

  /// Create the document referred to by the provided `DocumentReference`.
  /// The operation will fail the transaction if a document exists at the
  /// specified location.
  external Transaction create(
      DocumentReference documentRef, DocumentData? data);

  /// Writes to the document referred to by the provided `DocumentReference`.
  /// If the document does not exist yet, it will be created. If you pass
  /// `SetOptions`, the provided data can be merged into the existing document.
  external Transaction set(DocumentReference documentRef, DocumentData? data,
      [SetOptions? options]);

  /// Updates fields in the document referred to by the provided
  /// `DocumentReference`. The update will fail if applied to a document that
  /// does not exist.
  /// Nested fields can be updated by providing dot-separated field path
  /// strings.
  /// update the document.
  external Transaction update(DocumentReference documentRef, UpdateData data,
      [Precondition precondition]);

  /// Updates fields in the document referred to by the provided
  /// `DocumentReference`. The update will fail if applied to a document that
  /// does not exist.
  /// Nested fields can be updated by providing dot-separated field path
  /// strings or by providing FieldPath objects.
  /// A `Precondition` restricting this update can be specified as the last
  /// argument.
  /// to update, optionally followed by a `Precondition` to enforce on this
  /// update.
  /*external Transaction update(DocumentReference documentRef, String|FieldPath field, dynamic value, [dynamic fieldsOrPrecondition1, dynamic fieldsOrPrecondition2, dynamic fieldsOrPrecondition3, dynamic fieldsOrPrecondition4, dynamic fieldsOrPrecondition5]);
  external Transaction update(
    DocumentReference documentRef,
    //String /*String|FieldPath*/ dataField,
    //[dynamic /*Precondition|dynamic*/ preconditionValue,
    //List<dynamic>? fieldsOrPrecondition]
  );*/

  /// Deletes the document referred to by the provided `DocumentReference`.
  external Transaction delete(DocumentReference documentRef,
      [Precondition? precondition]);
}

/// A write batch, used to perform multiple writes as a single atomic unit.
///
/// A [WriteBatch] object can be acquired by calling [Firestore.batch]. It
/// provides methods for adding writes to the write batch. None of the
/// writes will be committed (or visible locally) until [WriteBatch.commit]
/// is called.
///
/// Unlike transactions, write batches are persisted offline and therefore are
/// preferable when you don't need to condition your writes on read data.
extension type WriteBatch._(js.JSObject _) implements js.JSObject {}

extension WriteBatchExt on WriteBatch {
  /// Create the document referred to by the provided [DocumentReference]. The
  /// operation will fail the batch if a document exists at the specified
  /// location.
  external WriteBatch create(DocumentReference documentRef, DocumentData data);

  /// Write to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created. If you pass
  /// [options], the provided data can be merged into the existing document.
  external WriteBatch set(DocumentReference documentRef, DocumentData? data,
      [SetOptions? options]);

  /// Updates fields in the document referred to by this DocumentReference.
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Nested fields can be updated by providing dot-separated field path strings
  external WriteBatch update(DocumentReference documentRef, UpdateData? data);

  /// Deletes the document referred to by the provided `DocumentReference`.
  external WriteBatch delete(DocumentReference documentRef);

  /// Commits all of the writes in this write batch as a single atomic unit.
  external js.JSPromise commit();
}

/// An options object that configures conditional behavior of `update()` and
/// `delete()` calls in `DocumentReference`, `WriteBatch`, and `Transaction`.
/// Using Preconditions, these calls can be restricted to only apply to
/// documents that match the specified restrictions.
extension type Precondition._(js.JSObject _) implements js.JSObject {
  external factory Precondition({Timestamp? lastUpdateTime});
}

extension PreconditionExt on Precondition {
  /// If set, the last update time to enforce (specified as an ISO 8601
  /// string).
  external Timestamp get lastUpdateTime;

  external set lastUpdateTime(Timestamp v);
}

/// An options object that configures the behavior of `set()` calls in
/// `DocumentReference`, `WriteBatch` and `Transaction`. These calls can be
/// configured to perform granular merges instead of overwriting the target
/// documents in their entirety by providing a `SetOptions` with `merge: true`.
extension type SetOptions._(js.JSObject _) implements js.JSObject {
  external factory SetOptions({bool? merge});
}

extension SetOptionsExt on SetOptions {
  /// Changes the behavior of a set() call to only replace the values specified
  /// in its data argument. Fields omitted from the set() call remain
  /// untouched.
  external bool get merge;

  external set merge(bool v);
}

/// A WriteResult wraps the write time set by the Firestore servers on `sets()`,
/// `updates()`, and `creates()`.
extension type WriteResult._(js.JSObject _) implements js.JSObject {}

extension WriteResultExt on WriteResult {
  /// The write time as set by the Firestore servers. Formatted as an ISO-8601
  /// string.
  external Timestamp get writeTime;

  external set writeTime(Timestamp v);
}

/// A `DocumentReference` refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location. The document at
/// the referenced location may or may not exist. A `DocumentReference` can
/// also be used to create a `CollectionReference` to a subcollection.
extension type DocumentReference._(js.JSObject _) implements js.JSObject {}

extension DocumentReferenceExt on DocumentReference {
  /// The identifier of the document within its collection.
  external String get id;

  external set id(String v);

  /// The `Firestore` for the Firestore database (useful for performing
  /// transactions, etc.).
  external Firestore get firestore;

  external set firestore(Firestore v);

  /// A reference to the Collection to which this DocumentReference belongs.
  external CollectionReference get parent;

  external set parent(CollectionReference v);

  /// A string representing the path of the referenced document (relative
  /// to the root of the database).
  external String get path;

  external set path(String v);

  /// Gets a `CollectionReference` instance that refers to the collection at
  /// the specified path.
  external CollectionReference collection(String collectionPath);

  /// Fetches the subcollections that are direct children of this document.
  external js.JSPromise<js.JSArray<CollectionReference>> listCollections();

  /// Creates a document referred to by this `DocumentReference` with the
  /// provided object values. The write fails if the document already exists
  external js.JSPromise create(DocumentData data);

  /// Writes to the document referred to by this `DocumentReference`. If the
  /// document does not yet exist, it will be created. If you pass
  /// `SetOptions`, the provided data can be merged into an existing document.
  external js.JSPromise set(DocumentData? data, [SetOptions? options]);

  /// Updates fields in the document referred to by this `DocumentReference`.
  /// The update will fail if applied to a document that does not exist.
  /// Nested fields can be updated by providing dot-separated field path
  /// strings.
  /// update the document.
  external js.JSPromise update(UpdateData? data, [Precondition? precondition]);

  /// Updates fields in the document referred to by this `DocumentReference`.
  /// The update will fail if applied to a document that does not exist.
  /// Nested fields can be updated by providing dot-separated field path
  /// strings or by providing FieldPath objects.
  /// A `Precondition` restricting this update can be specified as the last
  /// argument.
  /// values to update, optionally followed by a `Precondition` to enforce on
  /// this update.
  /*external js.JSPromise<WriteResult> update(String|FieldPath field, dynamic value, [dynamic moreFieldsOrPrecondition1, dynamic moreFieldsOrPrecondition2, dynamic moreFieldsOrPrecondition3, dynamic moreFieldsOrPrecondition4, dynamic moreFieldsOrPrecondition5]);*/
  // external js.JSPromise update(dynamic /*String|FieldPath*/ data_field,
  //     [dynamic /*Precondition|dynamic*/ precondition_value,
  //     List<dynamic> moreFieldsOrPrecondition]);

  /// Deletes the document referred to by this `DocumentReference`.
  external js.JSPromise delete([Precondition? precondition]);

  /// Reads the document referred to by this `DocumentReference`.
  /// current document contents.
  external js.JSPromise<DocumentSnapshot> get();

  /// Attaches a listener for DocumentSnapshot events.
  /// is available.
  /// cancelled. No further callbacks will occur.
  /// the snapshot listener.
  external js.JSFunction onSnapshot(
      js.JSFunction onNext, js.JSFunction onError);
//void Function(DocumentSnapshot snapshot) onNext,
//[void Function(Error error)? onError]);
}

/// A `DocumentSnapshot` contains data read from a document in your Firestore
/// database. The data can be extracted with `.data()` or `.get(<field>)` to
/// get a specific field.
/// For a `DocumentSnapshot` that points to a non-existing document, any data
/// access will return 'undefined'. You can use the `exists` property to
/// explicitly verify a document's existence.
extension type DocumentSnapshot._(js.JSObject _) implements js.JSObject {}

extension DocumentSnapshotExt on DocumentSnapshot {
  /// True if the document exists.
  external bool get exists;

  external set exists(bool v);

  /// A `DocumentReference` to the document location.
  external DocumentReference get ref;

  external set ref(DocumentReference v);

  /// The ID of the document for which this `DocumentSnapshot` contains data.
  external String get id;

  external set id(String v);

  /// The time the document was created. Not set for documents that don't
  /// exist.
  external Timestamp? get createTime;

  external set createTime(Timestamp? v);

  /// The time the document was last updated (at the time the snapshot was
  /// generated). Not set for documents that don't exist.
  external Timestamp? get updateTime;

  external set updateTime(Timestamp? v);

  /// The time this snapshot was read.
  external Timestamp get readTime;

  external set readTime(Timestamp v);

  /// Retrieves all fields in the document as an Object. Returns 'undefined' if
  /// the document doesn't exist.
  external DocumentData? data();

  /// Retrieves the field specified by `fieldPath`.
  /// field exists in the document.
  external js.JSAny? get(String fieldPath);
// dynamic /*String|FieldPath*/ fieldPath);
}

/// A `QueryDocumentSnapshot` contains data read from a document in your
/// Firestore database as part of a query. The document is guaranteed to exist
/// and its data can be extracted with `.data()` or `.get(<field>)` to get a
/// specific field.
/// A `QueryDocumentSnapshot` offers the same API surface as a
/// `DocumentSnapshot`. Since query results contain only existing documents, the
/// `exists` property will always be true and `data()` will never return
/// 'undefined'.
extension type QueryDocumentSnapshot._(js.JSObject _)
    implements DocumentSnapshot {}

extension QueryDocumentSnapshotExt on QueryDocumentSnapshot {
  /// The time the document was created.
  external Timestamp? get createTime;

  external set createTime(Timestamp? v);

  /// The time the document was last updated (at the time the snapshot was
  /// generated).
  external Timestamp? get updateTime;

  external set updateTime(Timestamp? v);

  /// Retrieves all fields in the document as an Object.
  /// @override
  external DocumentData data();
}

/// The direction of a `Query.orderBy()` clause is specified as 'desc' or 'asc'
/// (descending or ascending).
/*export type OrderByDirection = 'desc' | 'asc';*/

/// Filter conditions in a `Query.where()` clause are specified using the
/// strings `<`, `<=`, `==`, `>=`, and `>`.
/*export type WhereFilterOp = `<` | `<=` | `==` | `>=` | `>`;*/

/// A `Query` refers to a Query which you can read or listen to. You can also
/// construct refined `Query` objects by adding filters and ordering.
extension type DocumentQuery._(js.JSObject _) implements js.JSObject {}

extension DocumentQueryExt on DocumentQuery {
  /// The `Firestore` for the Firestore database (useful for performing
  /// transactions, etc.).
  external Firestore get firestore;

  external set firestore(Firestore v);

  /// Creates and returns a new Query with the additional filter that documents
  /// must contain the specified field and that its value should satisfy the
  /// relation constraint provided.
  /// This function returns a new (immutable) instance of the Query (rather
  /// than modify the existing instance) to impose the filter.
  external DocumentQuery where(String fieldPath,
      String /*'<'|'<='|'=='|'>='|'>'*/ opStr, js.JSAny? value);

  /// Creates and returns a new Query that's additionally sorted by the
  /// specified field, optionally in descending order instead of ascending.
  /// This function returns a new (immutable) instance of the Query (rather
  /// than modify the existing instance) to impose the order.
  /// not specified, order will be ascending.
  external DocumentQuery orderBy(String fieldPath,
      [String? /*'desc'|'asc'*/ directionStr]);

  /// Creates and returns a new Query that's additionally limited to only
  /// return up to the specified number of documents.
  /// This function returns a new (immutable) instance of the Query (rather
  /// than modify the existing instance) to impose the limit.
  external DocumentQuery limit(num limit);

  /// Specifies the offset of the returned results.
  /// This function returns a new (immutable) instance of the Query (rather
  /// than modify the existing instance) to impose the offset.
  external DocumentQuery offset(num offset);

  /// Creates and returns a new Query instance that applies a field mask to
  /// the result and returns only the specified subset of fields. You can
  /// specify a list of field paths to return, or use an empty list to only
  /// return the references of matching documents.
  /// This function returns a new (immutable) instance of the Query (rather
  /// than modify the existing instance) to impose the field mask.
  external DocumentQuery select(
      [String /*String|FieldPath*/ field1,
      String /*String|FieldPath*/ field2,
      String /*String|FieldPath*/ field3,
      String /*String|FieldPath*/ field4,
      String /*String|FieldPath*/ field5]);

  DocumentQuery selectAll(List<String> fields) => callMethodVarArgs(
      'select'.toJS, fields.map((field) => field.toJS).toList());

  /// Creates and returns a new Query that starts at the provided document
  /// (inclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  /*external Query startAt(DocumentSnapshot snapshot);*/

  /// Creates and returns a new Query that starts at the provided fields
  /// relative to the order of the query. The order of the field values
  /// must match the order of the order by clauses of the query.
  /// of the query's order by.
  /*external Query startAt(
    [dynamic fieldValues1,
    dynamic fieldValues2,
    dynamic fieldValues3,
    dynamic fieldValues4,
    dynamic fieldValues5]);*/
  DocumentQuery startAt(List<js.JSAny?> values) =>
      callMethodVarArgs('startAt'.toJS, values);

  @js.JS('startAt')
  external DocumentQuery startAtDocumentSnapshot(DocumentSnapshot snapshot);

  /// Creates and returns a new Query that starts after the provided document
  /// (exclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  DocumentQuery startAfter(List<js.JSAny?> values) =>
      callMethodVarArgs('startAfter'.toJS, values);

  /// Creates and returns a new Query that starts after the provided fields
  /// relative to the order of the query. The order of the field values
  /// must match the order of the order by clauses of the query.
  /// of the query's order by.
  @js.JS('startAfter')
  external DocumentQuery startAfterDocumentSnapshot(DocumentSnapshot snapshot);

  /// Creates and returns a new Query that ends before the provided document
  /// (exclusive). The end position is relative to the order of the query. The
  /// document must contain all of the fields provided in the orderBy of this
  /// query.
  DocumentQuery endBefore(List<js.JSAny?> values) =>
      callMethodVarArgs('endBefore'.toJS, values);

  /// Creates and returns a new Query that ends before the provided fields
  /// relative to the order of the query. The order of the field values
  /// must match the order of the order by clauses of the query.
  /// of the query's order by.
  /*external Query endBefore(
    [dynamic fieldValues1,
    dynamic fieldValues2,
    dynamic fieldValues3,
    dynamic fieldValues4,
    dynamic fieldValues5]);*/
  @js.JS('endBefore')
  external DocumentQuery endBeforeDocumentSnapshot(DocumentSnapshot snapshot);

  /// Creates and returns a new Query that ends at the provided document
  /// (inclusive). The end position is relative to the order of the query. The
  /// document must contain all of the fields provided in the orderBy of this
  /// query.
  /*external Query endAt(DocumentSnapshot snapshot);*/

  /// Creates and returns a new Query that ends at the provided fields
  /// relative to the order of the query. The order of the field values
  /// must match the order of the order by clauses of the query.
  /// of the query's order by.
  DocumentQuery endAt(List<js.JSAny?> values) =>
      callMethodVarArgs('endAt'.toJS, values);

  @js.JS('endAt')
  external DocumentQuery endAtDocumentSnapshot(DocumentSnapshot snapshot);

  /// Executes the query and returns the results as a `QuerySnapshot`.
  external js.JSPromise<QuerySnapshot> get();

  /// Executes the query and returns the results as Node Stream.
  //external Readable stream();

  /// Attaches a listener for `QuerySnapshot `events.
  /// is available.
  /// cancelled. No further callbacks will occur.
  /// the snapshot listener.
  //external Function onSnapshot(void Function(QuerySnapshot snapshot) onNext,
  //    [void Function(Error error)? onError]);
  external js.JSFunction onSnapshot(
      js.JSFunction onNext, js.JSFunction onError);

  //    [void Function(Error error)? onError]);

  /// Returns a query that counts the documents in the result set of this query.
  external AggregateQuery count();

  // https://cloud.google.com/nodejs/docs/reference/firestore/latest/firestore/query
  /// Returns a query that can perform the given aggregations.
  external AggregateQuery aggregate(AggregateSpecs aggregateSpecs);
}

/// A `QuerySnapshot` contains zero or more `QueryDocumentSnapshot` objects
/// representing the results of a query. The documents can be accessed as an
/// array via the `docs` property or enumerated using the `forEach` method. The
/// number of documents can be determined via the `empty` and `size`
/// properties.
extension type QuerySnapshot._(js.JSObject _) implements js.JSObject {}

extension QuerySnapshotExt on QuerySnapshot {
  /// The query on which you called `get` or `onSnapshot` in order to get this
  /// `QuerySnapshot`.
  external DocumentQuery get query;

  external set query(DocumentQuery v);

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as added
  /// changes.
  external js.JSArray<DocumentChange>? docChanges();

  /// An array of all the documents in the QuerySnapshot.
  external js.JSArray<QueryDocumentSnapshot>? get docs;

  //external set docs(js.JSArray<QueryDocumentSnapshot> v);

  /// The number of documents in the QuerySnapshot.
  external num get size;

  external set size(num v);

  /// True if there are no documents in the QuerySnapshot.
  external bool get empty;

  external set empty(bool v);

  /// The time this query snapshot was obtained.
  external Timestamp get readTime;

  external set readTime(Timestamp v);

  /// Enumerates all of the documents in the QuerySnapshot.
  /// each document in the snapshot.
  external void forEach(
    js.JSFunction callback,
    //void Function(QueryDocumentSnapshot result) callback,
    //[dynamic thisArg]
  );
}

/// The type of of a `DocumentChange` may be 'added', 'removed', or 'modified'.
const documentChangeTypeAdded = 'added';
const documentChangeTypeRemoved = 'removed';
const documentChangeTypeModified = 'modified';

/// A `DocumentChange` represents a change to the documents matching a query.
/// It contains the document affected and the type of change that occurred.
extension type DocumentChange._(js.JSObject _) implements js.JSObject {
  external factory DocumentChange(
      {String? /*'added'|'removed'|'modified'*/ type,
      QueryDocumentSnapshot? doc,
      num? oldIndex,
      num? newIndex});
}

extension DocumentChangeExt on DocumentChange {
  /// The type of change ('added', 'modified', or 'removed').
  external String /*'added'|'removed'|'modified'*/ get type;

  external set type(String /*'added'|'removed'|'modified'*/ v);

  /// The document affected by this change.
  external QueryDocumentSnapshot get doc;

  external set doc(QueryDocumentSnapshot v);

  /// The index of the changed document in the result set immediately prior to
  /// this DocumentChange (i.e. supposing that all prior DocumentChange objects
  /// have been applied). Is -1 for 'added' events.
  external int get oldIndex;

  external set oldIndex(int v);

  /// The index of the changed document in the result set immediately after
  /// this DocumentChange (i.e. supposing that all prior DocumentChange
  /// objects and the current DocumentChange object have been applied).
  /// Is -1 for 'removed' events.
  external int get newIndex;

  external set newIndex(int v);
}

/// A `CollectionReference` object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from `Query`).
extension type CollectionReference._(js.JSObject _) implements DocumentQuery {}

extension CollectionReferenceExt on CollectionReference {
  /// The identifier of the collection.
  external String get id;

  external set id(String v);

  /// A reference to the containing Document if this is a subcollection, else
  /// null.
  external DocumentReference? /*DocumentReference|Null*/ get parent;

  external set parent(DocumentReference? /*DocumentReference|Null*/ v);

  /// A string representing the path of the referenced collection (relative
  /// to the root of the database).
  external String get path;

  external set path(String v);

  /// Get a `DocumentReference` for the document within the collection at the
  /// specified path. If no path is specified, an automatically-generated
  /// unique ID will be used for the returned DocumentReference.
  external DocumentReference doc([String? documentPath]);

  /// Add a new document to this collection with the specified data, assigning
  /// it a document ID automatically.
  /// newly created document after it has been written to the backend.
  external js.JSPromise<DocumentReference> add(DocumentData? data);
}

/// Sentinel values that can be used when writing document fields with set()
/// or update().
extension type FieldValues._(js.JSObject _) implements js.JSObject {}

extension FieldValuesExt on FieldValues {
  /// Returns a sentinel used with set() or update() to include a
  /// server-generated timestamp in the written data.
  external FieldValue serverTimestamp();

  /// Returns a sentinel for use with update() to mark a field for deletion.
  external FieldValue delete();

  /// Returns a special value that tells the server to union the given elements
  /// with any array value that already exists on the server.
  ///
  /// Can be used with set(), create() or update() operations.
  ///
  /// Each specified element that doesn't already exist in the array will be
  /// added to the end. If the field being modified is not already an array it
  /// will be overwritten with an array containing exactly the specified
  /// elements.
  FieldValue arrayUnion(List<js.JSAny?> elements) =>
      callMethodVarArgs('arrayUnion'.toJS, elements);

  /// Returns a special value that tells the server to remove the given elements
  /// from any array value that already exists on the server.
  ///
  /// Can be used with set(), create() or update() operations.
  ///
  /// All instances of each element specified will be removed from the array.
  /// If the field being modified is not already an array it will be overwritten
  /// with an empty array.
  FieldValue arrayRemove(List<js.JSAny?> elements) =>
      callMethodVarArgs('arrayRemove'.toJS, elements);
// external FieldValue arrayRemove(js.JSArray elements);

  /// Vector
  FieldValue vector(js.JSArray<js.JSAny> elements) =>
      callMethod('vector'.toJS, elements);
}

extension type FieldValue._(js.JSObject _) implements js.JSObject {}

extension type FieldPathPrototype._(js.JSObject _) implements js.JSObject {}

extension FieldPathPrototypeExt on FieldPathPrototype {
  /// Returns a special sentinel FieldPath to refer to the ID of a document.
  /// It can be used in queries to sort or filter by the document ID.
  external FieldPath documentId();
}

/// A FieldPath refers to a field in a document. The path may consist of a
/// single field name (referring to a top-level field in the document), or a
/// list of field names (referring to a nested field in the document).
extension type FieldPath._(js.JSObject _) implements js.JSObject {
  /// Creates a FieldPath from the provided field names. If more than one field
  /// name is provided, the path will point to a nested field in a document.
  external factory FieldPath(
      [String? fieldNames1,
      String? fieldNames2,
      String? fieldNames3,
      String? fieldNames4,
      String? fieldNames5]);
}

extension type AggregateFields._(js.JSObject _) implements js.JSObject {}

extension AggregateFieldsExt on AggregateFields {
  external AggregateField count();

  external AggregateField sum(String fieldPath);

  external AggregateField average(String fieldPath);
}

extension type AggregateSpecs._(js.JSObject _) implements js.JSObject {
  factory AggregateSpecs() => js.JSObject() as AggregateSpecs;
}

extension type AggregateSpec._(js.JSObject _) implements js.JSObject {
  external factory AggregateSpec();
}

extension AggregateSpecExt on AggregateSpec {
  external void count();

  external AggregateField sum(String fieldPath);

  external AggregateField average(String fieldPath);
}

extension type AggregateField._(js.JSObject _) implements js.JSObject {}

extension AggregateFieldExt on AggregateField {
  external String get type;
}

extension type AggregateFieldCount._(js.JSObject _) implements AggregateField {}

/// Aggregation query.
extension type AggregateQuery._(js.JSObject _) implements js.JSObject {}

/// Aggregation query.
extension AggregateQueryExt on AggregateQuery {
  /// Executes the query and returns the results as a `AggregateQuerySnapshot`.
  external js.JSPromise<AggregateQuerySnapshot> get();
}

/// The results of executing an aggregation query.
extension type AggregateQuerySnapshot._(js.JSObject _) implements js.JSObject {}

/// The results of executing an aggregation query.
extension AggregateQuerySnapshotExt on AggregateQuerySnapshot {
  /// Executes the query and returns the results as a `AggregateQuerySnapshot`.
  external js.JSObject data();
}

extension TekartikFirestoreNodeJsAnyExt on js.JSObject {
  bool isJSTimestamp() => has('_seconds') && has('_nanoseconds');

  // this.instanceof(firestoreModule.timestampProto as js.JSFunction);
  bool isJSGeoPoint() => has('_latitude') && has('_longitude');

  // instanceof(firestoreModule.geoPointProto as js.JSFunction);
  bool isJSDocumentReference() => has('_firestore') && has('_path');

  /// {'_values': [1]}
  bool isVector() => has('_values');
// [_firestore, _path, _converter]
// has('_latitude') && has('_longitude');
}
