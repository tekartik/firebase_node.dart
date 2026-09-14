@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_node_build/npm_build.dart';
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:test/test.dart';

/// Write a `package.json` in [path].
Future<void> writePackageJson(String path, Map<String, Object?> map) async {
  var file = File(join(path, 'package.json'));
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(map));
}

/// Write the `package.json` of an installed module.
Future<void> writeInstalled(String path, String name, String version) async {
  await writePackageJson(joinAll([path, 'node_modules', ...name.split('/')]), {
    'name': name,
    'version': version,
  });
}

Future<String> emptyDir(String name) async {
  var path = join('.dart_tool', 'tekartik_firebase_node_test', 'test', name);
  var dir = Directory(path);
  if (dir.existsSync()) {
    await dir.delete(recursive: true);
  }
  await dir.create(recursive: true);
  return path;
}

void main() {
  group('package_json_test', () {
    group('ok', () {
      var path = join(
        '.dart_tool',
        'tekartik_firebase_node_test',
        'test',
        'ok',
      );
      setUpAll(() async {
        await emptyDir('ok');
        await writePackageJson(path, {
          'dependencies': {
            firebaseAdminNpmPackageName: firebaseAdminNpmMinConstraint,
            googleCloudFirestoreNpmPackageName:
                googleCloudFirestoreNpmMinConstraint,
          },
          'devDependencies': {
            firebaseFunctionsNpmPackageName: firebaseFunctionsNpmMinConstraint,
          },
        });
        await writeInstalled(path, firebaseAdminNpmPackageName, '14.4.0');
        await writeInstalled(path, googleCloudFirestoreNpmPackageName, '9.1.0');
        await writeInstalled(path, firebaseFunctionsNpmPackageName, '7.3.2');
      });
      // The test helper itself
      firebaseNodePackageJsonTests(
        path: path,
        requiredDependencies: [
          firebaseAdminNpmPackageName,
          googleCloudFirestoreNpmPackageName,
        ],
      );
    });

    group('not installed', () {
      var path = join(
        '.dart_tool',
        'tekartik_firebase_node_test',
        'test',
        'not_installed',
      );
      setUpAll(() async {
        await emptyDir('not_installed');
        await writePackageJson(path, {
          'dependencies': {firebaseAdminNpmPackageName: '>=14.4.0'},
        });
      });
      // installed test skipped as node_modules does not exist
      firebaseNodePackageJsonTests(path: path);
    });

    test('below min', () async {
      var path = await emptyDir('below_min');
      await writePackageJson(path, {
        'dependencies': {firebaseAdminNpmPackageName: '^14.2.0'},
      });
      await writeInstalled(path, firebaseAdminNpmPackageName, '14.2.0');
      var result = await nodePackageNpmCheck(
        path,
        minConstraints: firebaseNodeNpmMinConstraints,
        requiredDependencies: [firebaseFunctionsNpmPackageName],
      );
      expect(result.constraintIssues, [
        'firebase-admin: "^14.2.0" is below min ^14.4.0',
        'firebase-functions: missing in package.json (min ^7.3.2)',
      ]);
      expect(result.installedIssues, [
        'firebase-admin: installed 14.2.0 is below min ^14.4.0',
      ]);
      // Nothing installed (package.json not ok and no updatePackageJson)
      result = await firebaseNodePackageNpmInstallIfNeeded(path);
      expect(result.isOk, isFalse);
      expect(
        await nodePackageNpmCheck(path),
        isA<NodePackageNpmCheckResult>().having(
          (result) => result.dependencies.first.installedVersion,
          'installedVersion',
          Version(14, 2, 0),
        ),
      );
    });
  });
}
