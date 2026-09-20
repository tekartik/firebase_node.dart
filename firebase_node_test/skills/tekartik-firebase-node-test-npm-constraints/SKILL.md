---
name: tekartik-firebase-node-test-npm-constraints
description: >-
  Use when a dart node package must check its package.json firebase npm
  dependencies in its own tests or CI with tekartik_firebase_node_test:
  firebaseNodePackageJsonTests in test/package_json_test.dart,
  firebaseNodePackageNpmInstallIfNeeded in a tool script, the
  firebaseNodeNpmMinConstraints map and the firebaseAdminNpmPackageName /
  firebaseFunctionsNpmPackageName / googleCloudFirestoreNpmPackageName /
  firebaseAdminNpmMinConstraint constants, and the re-exported
  nodePackageNpmCheck, nodePackageNpmInstallIfNeeded,
  NodePackageNpmCheckResult and NodePackageNpmDependencyCheck helpers.
---

# Firebase node npm constraints tests (tekartik_firebase_node_test)

`tekartik_firebase_node_test` is the tiny test helper shared by the
`tekartik_firebase_*_node` packages (and any dart package compiled for
Node.js that uses the firebase npm modules). It declares a `package.json`
test group: the file exists, the firebase npm dependencies are declared with
a constraint at least the hard-coded minimum, and `node_modules` matches. It
contains no firebase code and never talks to a firebase project.

## Guidelines

* Dependency (git, not on pub.dev), always a **dev** dependency:
  ```yaml
  dev_dependencies:
    tekartik_firebase_node_test:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_node_test
  ```
  It brings `tekartik_app_node_build` (the generic npm check) and `test`.
* One import does everything: `package:tekartik_firebase_node_test/firebase_node_test.dart`.
  It exports `npm_constraints.dart` (the constants),
  `firebaseNodePackageJsonTests`, `firebaseNodePackageNpmInstallIfNeeded` and,
  from `tekartik_app_node_build`, `nodePackageNpmCheck`,
  `nodePackageNpmInstallIfNeeded`, `NodePackageNpmCheckResult` and
  `NodePackageNpmDependencyCheck`. Import
  `package:tekartik_app_node_build/npm_build.dart` as well only for the
  version helpers (`npmVersionConstraintParse`,
  `npmVersionConstraintMinVersion`, `Version`, `VersionConstraint`).
* Standard usage: a `test/package_json_test.dart` marked `@TestOn('vm')` (it
  reads files with `dart:io`, it must not run on node or in a browser) calling
  `firebaseNodePackageJsonTests(requiredDependencies: [...])`. List in
  `requiredDependencies` the npm modules the package really needs:
  `firebaseAdminNpmPackageName` (`'firebase-admin'`),
  `firebaseFunctionsNpmPackageName` (`'firebase-functions'`),
  `googleCloudFirestoreNpmPackageName` (`'@google-cloud/firestore'`), or any
  other npm name as a plain string (`'@google-cloud/storage'`).
* What the group declares: `exists` (a `package.json` in `path`),
  `constraints` (`result.constraintIssues` empty) and `installed`
  (`result.installedIssues` empty, *skipped* when there is no `node_modules`,
  so a fresh checkout without `npm install` still passes). Named parameters:
  `path` (default `'.'`, the package being tested), `minConstraints` (default
  `firebaseNodeNpmMinConstraints`), `requiredDependencies`,
  `includeDevDependencies` (default true, npm `devDependencies` are checked
  too) and `checkInstalled` (false to drop the `installed` test).
* `firebaseNodeNpmMinConstraints` is a `const Map<String, String>` of npm name
  to minimum range: `firebase-admin: ^14.4.0`
  (`firebaseAdminNpmMinConstraint`), `firebase-functions: ^7.3.2`
  (`firebaseFunctionsNpmMinConstraint`), `@google-cloud/firestore: ^9.1.0`
  (`googleCloudFirestoreNpmMinConstraint`). Only the **lower bound** is
  enforced: `^14.4.0` and `>=14.5.0` pass, `^14.2.0` fails. A dependency not
  declared in `package.json` is only reported when it is in
  `requiredDependencies`. `npm_constraints.dart` can be imported alone
  (`package:tekartik_firebase_node_test/npm_constraints.dart`): pure
  constants, no `dart:io`.
* Fixing a package rather than asserting it: a `tool/` script calls
  `await firebaseNodePackageNpmInstallIfNeeded('.', updatePackageJson: true)`
  — `npm install` when the installed versions are stale,
  `npm install --save <name>@<minConstraint>` when `package.json` itself is
  below the minimum or missing a required dependency. Without
  `updatePackageJson: true` a bad `package.json` is only reported and nothing
  is installed; `force: true` always runs `npm install`, `verbose: true`
  traces. It is a no-op when there is no `package.json`. Never call it from a
  test.
* Inspect without touching anything with `await nodePackageNpmCheck(path,
  minConstraints: firebaseNodeNpmMinConstraints, requiredDependencies: [...])`:
  the `NodePackageNpmCheckResult` gives `packageJsonExists`,
  `nodeModulesExists`, `dependencies` (each `NodePackageNpmDependencyCheck`
  with `name`, `constraint`, `minConstraint`, `installedVersion`,
  `isDevDependency`, `isDeclared`), `constraintIssues`, `installedIssues`,
  `issues`, `isConstraintOk`, `isInstalledOk`, `isOk`, `npmInstallNeeded` and
  `constraintFailures`. Issue strings are human messages
  (`'firebase-admin: "^14.2.0" is below min ^14.4.0'`), do not parse them.
* Version bumps: when the minimum constraints move, the node packages'
  `package.json` must follow, otherwise their `package_json_test.dart` fails.
  Fix the `package.json` (or run the tool script above); do not lower
  `minConstraints` in the test.
* Run these tests with `dart test -p vm` (or plain `dart test` where
  `dart_test.yaml` lists `vm`); `tool/run_ci.dart` (`nodePackageRunCi('.')`
  from `package:tekartik_app_node_build/package.dart`) does it in CI.

## Examples

### test/package_json_test.dart of a firestore node package

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  // package.json exists, firebase-admin >= ^14.4.0,
  // @google-cloud/firestore >= ^9.1.0, node_modules up to date.
  firebaseNodePackageJsonTests(
    requiredDependencies: [
      firebaseAdminNpmPackageName,
      googleCloudFirestoreNpmPackageName,
    ],
  );
}
```

### Checking another directory, without the installed check

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

void main() {
  // The node package lives in a sub directory and is not installed in CI.
  firebaseNodePackageJsonTests(
    path: 'node',
    requiredDependencies: [firebaseFunctionsNpmPackageName],
    includeDevDependencies: false,
    checkInstalled: false,
  );
}
```

### tool/npm_install_if_needed.dart

```dart
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';

Future<void> main() async {
  // Runs npm install when needed and raises package.json constraints that
  // are below the firebase minimums.
  var result = await firebaseNodePackageNpmInstallIfNeeded(
    '.',
    requiredDependencies: [firebaseAdminNpmPackageName],
    updatePackageJson: true,
    verbose: true,
  );
  print(result.isOk ? 'up to date' : result.issues.join('\n'));
}
```

### Reporting the state of a package without modifying it

```dart
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';

Future<bool> reportNpmState(String path) async {
  var result = await nodePackageNpmCheck(
    path,
    minConstraints: firebaseNodeNpmMinConstraints,
    requiredDependencies: [firebaseAdminNpmPackageName],
  );
  for (var dependency in result.dependencies) {
    print(
      '${dependency.name}: ${dependency.constraint} '
      'min ${dependency.minConstraint} '
      'installed ${dependency.installedVersion ?? '(none)'}',
    );
  }
  if (result.npmInstallNeeded) {
    print('run npm install in $path');
  }
  return result.isOk;
}
```

### Asserting a minimum in your own test

```dart
@TestOn('vm')
library;

import 'package:tekartik_app_node_build/npm_build.dart';
import 'package:tekartik_firebase_node_test/npm_constraints.dart';
import 'package:test/test.dart';

void main() {
  test('firebase-admin min', () {
    expect(
      npmVersionConstraintMinVersion(
        firebaseNodeNpmMinConstraints[firebaseAdminNpmPackageName]!,
      ),
      greaterThanOrEqualTo(Version(14, 4, 0)),
    );
  });
}
```

## Common mistakes

* Forgetting `@TestOn('vm')`: the check reads `package.json` and
  `node_modules` from the file system.
* Expecting the `installed` test to fail without `node_modules`: it is
  skipped, `npm install` is what makes it meaningful.
* Calling `firebaseNodePackageNpmInstallIfNeeded` from a test: it runs
  `npm install` and may rewrite `package.json`; keep it in `tool/`.
* Passing `updatePackageJson: true` in CI and expecting a green build: the
  fix is a file change, commit it instead.
* Lowering `minConstraints` to make the test pass instead of bumping
  `package.json`.
* Listing a dependency in `requiredDependencies` under a dart name
  (`tekartik_firebase_node`): these are npm module names.
