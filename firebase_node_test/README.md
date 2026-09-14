# tekartik_firebase_node_test

Test helpers for the firebase node packages: checks that the `package.json`
of a node package declares the firebase npm dependencies (`firebase-admin`,
`firebase-functions`, `@google-cloud/firestore`) with constraints at least
the hard-coded minimum ones, and that the installed `node_modules` are up to
date.

## Setup

```yaml
dev_dependencies:
  tekartik_firebase_node_test:
    git:
      url: https://github.com/tekartik/firebase_node.dart
      path: firebase_node_test
```

## Usage

In `test/package_json_test.dart`:

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';

void main() {
  firebaseNodePackageJsonTests(
    requiredDependencies: [firebaseAdminNpmPackageName],
  );
}
```

The minimum constraints are defined in `firebaseNodeNpmMinConstraints`, only
their lower bound is enforced.

To update `package.json` and `node_modules` if needed (tool script):

```dart
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';

Future<void> main() async {
  await firebaseNodePackageNpmInstallIfNeeded('.', updatePackageJson: true);
}
```
