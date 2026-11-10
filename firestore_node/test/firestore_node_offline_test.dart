// No credentials, no network: what firebase-admin does locally.
@TestOn('node')
library;

import 'dart:js_interop';

import 'package:tekartik_firebase_firestore/firestore.dart';
import 'package:tekartik_firebase_firestore_node/firestore_node_interop.dart';
import 'package:tekartik_firebase_firestore_node/src/node/firestore_node.dart'
    show fromNativeValue, toNativeValue;
import 'package:tekartik_firebase_node/firebase_node_interop.dart';
import 'package:test/test.dart';

void main() {
  group('offline', () {
    test('an update function error fails the transaction with it', () async {
      var app = firebaseNode.initializeApp(
        options: FirebaseAppOptions(projectId: 'demo-offline'),
        name: 'firestore_node_offline',
      );
      try {
        var firestore = firestoreServiceNode.firestore(app);
        // Thrown before any read: nothing is sent.
        await expectLater(
          firestore.runTransaction<void>((txn) async {
            throw StateError('throwing');
          }),
          throwsA(
            isA<StateError>().having((e) => e.message, 'message', 'throwing'),
          ),
        );
        await expectLater(
          firestore.runTransaction<void>((txn) {
            throw ArgumentError('sync');
          }),
          throwsA(isA<ArgumentError>()),
        );
      } finally {
        await app.delete();
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('maps with the field names of a native value', () {
      // A map read from a document is a plain object.
      for (var map in [
        {'_seconds': 1, '_nanoseconds': 2},
        {'_latitude': 1.5, '_longitude': 2.5},
        {'_firestore': 'a', '_path': 'b'},
        {'_values': 1, 'toArray': 'text'},
      ]) {
        expect(fromNativeValue(map.jsify()!), map);
      }
      expect(fromNativeValue({'_seconds': 1}.jsify()!), {'_seconds': 1});
      expect(fromNativeValue(toNativeValue(Timestamp(1, 2))), Timestamp(1, 2));
      expect(
        fromNativeValue(toNativeValue(GeoPoint(1.5, 2.5))),
        GeoPoint(1.5, 2.5),
      );
    });
  });
}
