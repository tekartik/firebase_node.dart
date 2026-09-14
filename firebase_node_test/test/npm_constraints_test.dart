@TestOn('vm')
library;

import 'package:tekartik_app_node_build/npm_build.dart';
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  group('npm_constraints', () {
    test('valid', () {
      expect(firebaseNodeNpmMinConstraints, isNotEmpty);
      for (var entry in firebaseNodeNpmMinConstraints.entries) {
        var constraint = npmVersionConstraintParse(entry.value);
        expect(constraint, isNot(VersionConstraint.any), reason: entry.key);
        expect(
          npmVersionConstraintMinVersion(entry.value),
          isNotNull,
          reason: '${entry.key} ${entry.value} must have a lower bound',
        );
      }
    });

    test('values', () {
      expect(
        firebaseNodeNpmMinConstraints[firebaseAdminNpmPackageName],
        firebaseAdminNpmMinConstraint,
      );
      expect(
        firebaseNodeNpmMinConstraints[firebaseFunctionsNpmPackageName],
        firebaseFunctionsNpmMinConstraint,
      );
      expect(
        firebaseNodeNpmMinConstraints[googleCloudFirestoreNpmPackageName],
        googleCloudFirestoreNpmMinConstraint,
      );
      expect(
        npmVersionConstraintMinVersion(firebaseAdminNpmMinConstraint),
        greaterThanOrEqualTo(Version(14, 4, 0)),
      );
    });
  });
}
