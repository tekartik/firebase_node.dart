import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_firebase_node_test/firebase_node_test.dart';
import 'package:tekartik_firebase_test/ci_shell_io.dart';

var topDir = join('..', '..');

/// Test service account, either a json path or the json content itself.
const serviceAccountEnvKey = 'TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT';

/// Application default credentials, a json file path.
const googleApplicationCredentialsEnvKey = 'GOOGLE_APPLICATION_CREDENTIALS';

/// The `firebase admin access token` test uses the application default
/// credentials (`firebase.credential.applicationDefault()`), which are not the
/// test service account: point them to it when they are not set, the json
/// content being written to a file first (github) since only a path is
/// supported.
Shell shellWithApplicationDefaultCredentials(Shell shell) {
  var vars = shell.options.environment.vars;
  if (vars[googleApplicationCredentialsEnvKey]?.isNotEmpty ?? false) {
    return shell;
  }
  var serviceAccount = vars[serviceAccountEnvKey];
  if (serviceAccount == null) {
    return shell;
  }
  String path;
  if (serviceAccount.startsWith('{')) {
    path = join(
      Directory.systemTemp.createTempSync('firebase_node_ci').path,
      'service_account.json',
    );
    File(path).writeAsStringSync(serviceAccount);
  } else {
    path = serviceAccount;
  }
  var environment = ShellEnvironment.full(
    environment: shell.options.environment,
  )..vars[googleApplicationCredentialsEnvKey] = path;
  return shell.cloneWithOptions(
    shell.options.clone(shellEnvironment: environment),
  );
}

Future<void> main() async {
  var path = join(topDir, 'firebase_node');
  await firebaseNodePackageNpmInstallIfNeeded(path);
  var shell = shellWithApplicationDefaultCredentials(
    firebaseGithubActionEnvTestShell(path),
  );
  await shell.run('dart test -p node test/firebase_node_test.dart');
}
