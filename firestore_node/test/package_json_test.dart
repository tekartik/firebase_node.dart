@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  firebaseNodePackageJsonTests(
    requiredDependencies: [
      firebaseAdminNpmPackageName,
      googleCloudFirestoreNpmPackageName,
    ],
  );
}
