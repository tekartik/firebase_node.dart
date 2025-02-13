@TestOn('node')
library;

import 'dart:js_interop';

import 'package:tekartik_firebase_firestore/firestore.dart' as firestore;
import 'package:tekartik_firebase_firestore_node/src/node/firestore_node.dart';
import 'package:tekartik_firebase_firestore_node/src/node/firestore_node_js_interop.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:test/test.dart';

void main() {
  // ignore: unnecessary_statements
  firebaseAdminFirestoreModule;
  group('no_app', () {
    test('FieldValue', () {
      print(jsObjectKeys(firebaseAdminFirestoreModule));
      // [AggregateField, AggregateQuery, AggregateQuerySnapshot, BulkWriter,
      // BundleBuilder, CollectionGroup, CollectionReference, DocumentReference,
      // DocumentSnapshot, FieldPath, FieldValue, Filter, Firestore, GeoPoint,
      // GrpcStatus, Query, QueryDocumentSnapshot, QueryPartition, QuerySnapshot,
      // Timestamp, Transaction, WriteBatch, WriteResult, v1, setLogFunction,
      // getFirestore, initializeFirestore]
      print(jsObjectKeys(cloudFirestoreModule));

      print(jsObjectKeys(firebaseAdminFirestoreModule.fieldValue));
      print(jsObjectKeys(cloudFirestoreModule.fieldValue));
      print(firebaseAdminFirestoreModule.fieldValue.serverTimestamp());
      print(cloudFirestoreModule.fieldValue.serverTimestamp());
      expect(
        firebaseAdminFirestoreModule.fieldValue.serverTimestamp(),
        cloudFirestoreModule.fieldValue.serverTimestamp(),
      );
      print(
        jsObjectKeys(
          firebaseAdminFirestoreModule.fieldValue.vector([.5.toJS].toJS),
        ),
      );
      // [_values]
    });
    test('Bytes', () {
      //var jsUint8Array = Uint8List.fromList([1, 2, 3]).toJS;
    });
    test('Aggregate fields', () {
      print(jsObjectKeys(firebaseAdminFirestoreModule.aggregateFields));
      print(jsObjectKeys(firebaseAdminFirestoreModule.aggregateFields.count()));
    });
    test('Timestamp', () {
      print(jsObjectKeys(firebaseAdminFirestoreModule.timestampProto.now()));
      // [_seconds, _nanoseconds]
      print(
        jsObjectKeys(
          firebaseAdminFirestoreModule.timestampProto.fromSecondsAndNanoseconds(
            1,
            2,
          ),
        ),
      );
      var timestamp = firebaseAdminFirestoreModule.timestampProto
          .fromSecondsAndNanoseconds(1, 2000);
      // expect(timestamp, isA<Timestamp>()); // !! Invalid test
      expect(timestamp.seconds, 1);
      expect(timestamp.nanoseconds, 2000);
      expect(timestamp.isJSTimestamp(), isTrue);
      expect(timestamp.isJSGeoPoint(), isFalse);
    });
    test('GeoPoint', () {
      print(jsObjectKeys(firestoreModule.geoPointProto));
      var geoPoint = firestoreModule.geoPointProto.fromLatitudeAndLongitude(
        1,
        2,
      );
      expect(geoPoint.isJSTimestamp(), isFalse);
      expect(geoPoint.isJSGeoPoint(), isTrue);
      expect(geoPoint.latitude, 1);
      expect(geoPoint.longitude, 2);
      print(jsObjectKeys(geoPoint));
      // [_latitude, _longitude]
      //print(jsObjectKeys(geoPoint.getProperty('__proto__'.toJS)));
      //print(geoPoint.instanceOfString('GeoPoint')); // false
      // print(geoPoint.instanceof(firestoreModule.geoPointProto as JSFunction));
    });
    test('Vector', () {
      //print(jsObjectKeys(firestoreModule.vectorProto));
      var geoPoint = firestoreModule.geoPointProto.fromLatitudeAndLongitude(
        1,
        2,
      );
      expect(geoPoint.isJSTimestamp(), isFalse);
      expect(geoPoint.isJSGeoPoint(), isTrue);
      expect(geoPoint.latitude, 1);
      expect(geoPoint.longitude, 2);
      print(jsObjectKeys(geoPoint));
      // [_latitude, _longitude]
      //print(jsObjectKeys(geoPoint.getProperty('__proto__'.toJS)));
      //print(geoPoint.instanceOfString('GeoPoint')); // false
      // print(geoPoint.instanceof(firestoreModule.geoPointProto as JSFunction));
    });
    test('fromToNative', () {
      void testRoundTrip(Object? value) {
        expect(fromNativeValueOrNull(toNativeValueOrNull(value)), value);
      }

      testRoundTrip(null);
      testRoundTrip(1);
      testRoundTrip(1.5);
      testRoundTrip('text');
      //testRoundTrip(DateTime.utc(2024, 6, 11));
      testRoundTrip(firestore.Timestamp(1, 2000));
      testRoundTrip(firestore.GeoPoint(1.5, 2.5));
      testRoundTrip([]);
      testRoundTrip(<String, Object?>{});
      testRoundTrip([1]);
      testRoundTrip({'test': 1});
      testRoundTrip([firestore.Timestamp(1, 2000)]);
      testRoundTrip({'test': firestore.Timestamp(1, 2000)});
      testRoundTrip(firestore.VectorValue([1]));
    });
    test('documentValueToNativeValue', () {});
  });
}
