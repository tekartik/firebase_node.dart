@TestOn('node')
library;

import 'dart:js_interop';

import 'package:tekartik_firebase_auth/utils/json_utils.dart';
import 'package:tekartik_firebase_auth_node/auth_node.dart';
import 'package:tekartik_firebase_auth_node/src/node/auth_node.dart';
import 'package:tekartik_firebase_auth_node/src/node/auth_node_js_interop.dart'
    as node;
import 'package:test/test.dart';

/// A record as firebase-admin builds it: the missing fields are undefined
/// (no phone, no photo, no password hash out of listUsers, no isAnonymous).
node.UserRecord _nativeUserRecord(Map<String, Object?> map) =>
    map.jsify() as node.UserRecord;

const _metadata = {'creationTime': 'Thu, 13 Jun 2024 10:06:33 GMT'};

void main() {
  group('user record', () {
    test('email/password user, optional fields absent', () {
      UserRecord user = UserRecordNode(
        _nativeUserRecord({
          'uid': 'u1',
          'email': 'a@b.c',
          'emailVerified': false,
          'disabled': false,
          'metadata': _metadata,
          'providerData': [
            {'uid': 'a@b.c', 'email': 'a@b.c', 'providerId': 'password'},
          ],
        }),
      );
      expect(user.uid, 'u1');
      expect(user.email, 'a@b.c');
      expect(user.displayName, isNull);
      expect(user.phoneNumber, isNull);
      expect(user.photoURL, isNull);
      expect(user.passwordHash, isNull);
      expect(user.passwordSalt, isNull);
      expect(user.tokensValidAfterTime, isNull);
      expect(user.customClaims, isNull);
      expect(user.isAnonymous, isFalse);
      expect(user.metadata!.lastSignInTime, '');
      var info = user.providerData!.single;
      expect(info.providerId, 'password');
      expect(info.email, 'a@b.c');
      expect(info.displayName, isNull);
      expect(info.phoneNumber, isNull);
      expect(info.photoURL, isNull);
      expect(userRecordToJson(user), {'uid': 'u1', 'email': 'a@b.c'});
    });
    test('listed user with a password and custom claims', () {
      UserRecord user = UserRecordNode(
        _nativeUserRecord({
          'uid': 'u2',
          'email': 'a@b.c',
          'emailVerified': true,
          'disabled': false,
          'metadata': _metadata,
          'providerData': [
            {'uid': 'a@b.c', 'email': 'a@b.c', 'providerId': 'password'},
          ],
          'passwordHash': 'hash',
          'passwordSalt': 'salt',
          'phoneNumber': '+1234567890',
          'tokensValidAfterTime': 'Thu, 13 Jun 2024 10:06:33 GMT',
          'customClaims': {
            'admin': true,
            'level': 2,
            'roles': ['a'],
          },
        }),
      );
      expect(user.passwordHash, 'hash');
      expect(user.passwordSalt, 'salt');
      expect(user.phoneNumber, '+1234567890');
      expect(user.tokensValidAfterTime, isNotNull);
      expect(user.customClaims, {
        'admin': true,
        'level': 2,
        'roles': ['a'],
      });
      expect((user.customClaims as Map)['admin'], isTrue);
    });

    test('toString shows the uid and email only', () {
      // It printed the whole record, the password hash and salt of a
      // listUsers record included (the shared listUsers test prints one).
      var user = UserRecordNode(
        _nativeUserRecord({
          'uid': 'u3',
          'email': 'a@b.c',
          'emailVerified': true,
          'disabled': false,
          'metadata': _metadata,
          'providerData': <Object?>[],
          'passwordHash': 'secret_hash',
          'passwordSalt': 'secret_salt',
        }),
      );
      expect(user.toString(), 'UserRecordNode(u3, a@b.c)');
    });
    test('anonymous user', () {
      UserRecord user = UserRecordNode(
        _nativeUserRecord({
          'uid': 'u3',
          'emailVerified': false,
          'disabled': false,
          'metadata': _metadata,
          'providerData': <Object?>[],
        }),
      );
      expect(user.isAnonymous, isTrue);
      expect(user.email, isNull);
      expect(user.providerData, isEmpty);
    });
  });
}
