// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_node/src/node/firebase_node.dart';
import 'package:tekartik_fs_node/fs_node_universal.dart';
import 'package:tekartik_platform/util/github_util.dart';
import 'package:tekartik_platform_node/context_universal.dart';

/// Json (if starting with { or path
const _envServiceAccount = 'TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT';

String? _envGetServiceAccountJsonOrPath() {
  return platform.environment[_envServiceAccount];
}

/// Setup
///
/// When [verbose] is true, the steps and the resulting context are printed
/// (never the private key), see `tool/setup_io_env_verbose.dart`.
Future<FirebaseNodeTestContext?> setupOrNull({
  bool? useEnv,
  Map<String, Object?>? serviceAccountMap,
  bool? verbose,
}) async {
  try {
    return await setup(
      useEnv: useEnv,
      serviceAccountMap: serviceAccountMap,
      verbose: verbose,
    );
  } catch (e, st) {
    print('Error: $e');
    if (verbose ?? false) {
      print(st);
    }
    return null;
  }
}

/// Setup
///
/// When [verbose] is true, each step is printed (never the private key).
Future<FirebaseNodeTestContext> setup({
  bool? useEnv,
  Map<String, Object?>? serviceAccountMap,
  bool? verbose,
}) async {
  void log(String message) {
    if (verbose ?? false) {
      print('# setup: $message');
    }
  }

  log(
    'platform: $_platformName, useEnv: $useEnv, '
    'serviceAccountMap: ${serviceAccountMap != null}',
  );

  Map<String, Object?> serviceAccountFromString(String jsonString) {
    log('parsing service account json (${jsonString.length} chars)');
    return (jsonDecode(jsonString) as Map).cast<String, Object?>();
  }

  var serviceAccountJsonOrPath = _envGetServiceAccountJsonOrPath();
  if (serviceAccountJsonOrPath == null) {
    log('env $_envServiceAccount not set');
    throw UnsupportedError(
      'Missing env TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT',
    );
  }

  Future<Map<String, Object?>> serviceAccountFromPath(String path) async {
    log('reading service account file $path');
    try {
      var serviceAccountJsonString = await fs.file(path).readAsString();

      return serviceAccountFromString(serviceAccountJsonString);
    } catch (e) {
      log('cannot read $path: $e');
      throw (StateError('Cannot read $path'));
    }
  }

  Map<String, Object?> jsonData;
  if (serviceAccountMap != null) {
    log('using the service account map given');
    jsonData = serviceAccountMap;
  } else if (useEnv == true) {
    var serviceAccountJsonOrPath = _envGetServiceAccountJsonOrPath();
    if (serviceAccountJsonOrPath == null) {
      log('env $_envServiceAccount not set');
      throw (StateError('$_envServiceAccount not set'));
    }
    if (serviceAccountJsonOrPath.startsWith('{')) {
      log('env $_envServiceAccount holds the service account json');
      jsonData = serviceAccountFromString(serviceAccountJsonOrPath);
    } else {
      log('env $_envServiceAccount holds a path');
      jsonData = await serviceAccountFromPath(serviceAccountJsonOrPath);
    }
  } else {
    log('neither useEnv nor serviceAccountMap');
    throw UnsupportedError('Need useEnv or serviceAccountMap');
  }

  var context = FirebaseNodeTestContext(serviceAccount: jsonData);
  log('context: $context');
  log('service account fields: ${jsonData.keys.toList()..sort()}');
  return context;
}

/// Test context
class FirebaseNodeTestContext {
  /// Service account
  final Map<String, Object?> serviceAccount;

  /// App options
  FirebaseAppOptions get appOptions =>
      firebaseNodeAppOptionsFromServiceAccountMap(serviceAccount);

  /// Service account project id
  String? get projectId => serviceAccount['project_id']?.toString();

  /// Service account client email
  String? get clientEmail => serviceAccount['client_email']?.toString();

  /// Constructor
  FirebaseNodeTestContext({required this.serviceAccount});

  /// Never displays the private key.
  @override
  String toString() =>
      'FirebaseNodeTestContext(projectId: $projectId, '
      'clientEmail: $clientEmail, type: ${serviceAccount['type']})';
}

/// True if running on github
bool get runningOnGithub => platform.runningOnGithub;

String get _platformName => platform.isLinux
    ? 'linux'
    : platform.isMacOS
    ? 'macos'
    : platform.isWindows
    ? 'windows'
    : 'unknown';

/// Github actions prefix
final githubActionsPrefix = 'ga_$_platformName';

/// Env variable set by the dedicated env test workflows
/// (`run_ci_<name>_test.yml`) through
/// `repo_support/workflow_ci_<name>_test/tool/run_ci.dart`, which uses
/// `firebaseGithubActionEnvTestShell` (`package:tekartik_firebase_test/ci_shell_io.dart`).
///
/// It is not set by the regular run_ci.yml workflow.
const githubActionsEnvTestEnvKey = 'TEKARTIK_GITHUB_ACTIONS_ENV_TEST';

/// True if the env tests (needing the private service account) are explicitly
/// requested, i.e. when running the dedicated env test workflow.
bool isGithubActionsEnvTest() =>
    platform.environment[githubActionsEnvTestEnvKey] == 'true';

/// True if the env tests (needing the private service account) must be
/// skipped.
///
/// On github they are only run by the dedicated env test workflow
/// (`run_ci_<name>_test.yml`), on linux. Outside of github they are always run
/// (when the env is available).
bool shouldSkipEnvTestOnGithub() =>
    runningOnGithub && (!isGithubActionsEnvTest() || !platform.isLinux);
