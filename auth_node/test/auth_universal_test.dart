import 'package:tekartik_firebase_auth_node/auth_universal.dart';
import 'package:test/test.dart';

void main() {
  group('auth_universal', () {
    test('authService', () {
      expect(authService, isNotNull);
    });
  });
}
