import 'package:path/path.dart';
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:tekartik_firebase_test/ci_shell_io.dart';

var topDir = join('..', '..');

Future<void> main() async {
  var path = join(topDir, 'storage_node');
  await firebaseNodePackageNpmInstallIfNeeded(path);
  var shell = firebaseGithubActionEnvTestShell(path);
  await shell.run('dart test -p node test/storage_node_test.dart');
}
