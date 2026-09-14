import 'package:path/path.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';

var topDir = '..';

/// Check every node package `package.json` against the hard-coded minimum
/// npm constraints ([firebaseNodeNpmMinConstraints]), bump `package.json`
/// (`npm install --save <name>@<min>`) if below and run `npm install` when
/// `node_modules` is missing or not up to date.
Future<void> main() async {
  var failures = <String>[];
  for (var dir in [
    'firebase_node',
    'auth_node',
    'firestore_node',
    'functions_node',
    join('functions_node', 'deploy', 'functions'),
    'storage_node',
  ]) {
    var path = join(topDir, dir);
    stdout.writeln('# $dir');
    var result = await firebaseNodePackageNpmInstallIfNeeded(
      path,
      updatePackageJson: true,
    );
    if (!result.isOk) {
      failures.add(dir);
    }
  }
  if (failures.isNotEmpty) {
    stderr.writeln('# not up to date: ${failures.join(', ')}');
    exitCode = 1;
  }
}
