import 'package:tekartik_app_node_build/npm_build.dart';
import 'package:test/test.dart';

import '../npm_constraints.dart';

/// Declares tests checking the `package.json` of the node package in [path]
/// (default to the current directory, i.e. the package being tested):
/// - `package.json` exists
/// - every declared dependency listed in [minConstraints] (default to
///   [firebaseNodeNpmMinConstraints]) has a lower bound at least the minimum
///   one
/// - every name in [requiredDependencies] is declared
/// - if `node_modules` exists (the test is skipped otherwise), every declared
///   dependency is installed with a version matching `package.json` and the
///   minimum constraint. Set [checkInstalled] to false to skip this test.
///
/// `devDependencies` are checked too unless [includeDevDependencies] is false.
///
/// Typically in `test/package_json_test.dart`:
/// ```dart
/// @TestOn('vm')
/// library;
///
/// import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
///
/// void main() {
///   firebaseNodePackageJsonTests(
///     requiredDependencies: [firebaseAdminNpmPackageName],
///   );
/// }
/// ```
void firebaseNodePackageJsonTests({
  String path = '.',
  Map<String, String>? minConstraints,
  List<String>? requiredDependencies,
  bool includeDevDependencies = true,
  bool checkInstalled = true,
}) {
  minConstraints ??= firebaseNodeNpmMinConstraints;
  group('package.json', () {
    late NodePackageNpmCheckResult result;
    setUpAll(() async {
      result = await nodePackageNpmCheck(
        path,
        minConstraints: minConstraints,
        requiredDependencies: requiredDependencies,
        includeDevDependencies: includeDevDependencies,
      );
    });
    test('exists', () {
      expect(
        result.packageJsonExists,
        isTrue,
        reason: 'package.json not found in $path',
      );
    });
    test('constraints', () {
      expect(
        result.constraintIssues,
        isEmpty,
        reason: 'package.json in $path (min $minConstraints)',
      );
    });
    test('installed', () {
      if (!result.nodeModulesExists) {
        markTestSkipped('node_modules not found in $path, run npm install');
        return;
      }
      expect(
        result.installedIssues,
        isEmpty,
        reason: 'node_modules in $path not up to date, run npm install',
      );
    }, skip: !checkInstalled);
  });
}

/// Checks the `package.json` and `node_modules` of the node package in [path]
/// against [minConstraints] (default to [firebaseNodeNpmMinConstraints]) and
/// runs `npm install` if needed, see [nodePackageNpmInstallIfNeeded].
///
/// If [updatePackageJson] is true, a `package.json` constraint below the
/// minimum (or a missing required dependency) is fixed with
/// `npm install --save <name>@<minConstraint>`.
Future<NodePackageNpmCheckResult> firebaseNodePackageNpmInstallIfNeeded(
  String path, {
  Map<String, String>? minConstraints,
  List<String>? requiredDependencies,
  bool includeDevDependencies = true,
  bool updatePackageJson = false,
  bool force = false,
  bool verbose = false,
}) => nodePackageNpmInstallIfNeeded(
  path,
  minConstraints: minConstraints ?? firebaseNodeNpmMinConstraints,
  requiredDependencies: requiredDependencies,
  includeDevDependencies: includeDevDependencies,
  updatePackageJson: updatePackageJson,
  force: force,
  verbose: verbose,
);
