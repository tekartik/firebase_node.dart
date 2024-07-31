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
Future<FirebaseNodeTestContext?> setupOrNull({
  bool? useEnv,
  Map<String, Object?>? serviceAccountMap,
}) async {
  try {
    return await setup(useEnv: useEnv, serviceAccountMap: serviceAccountMap);
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

/// Setup
Future<FirebaseNodeTestContext> setup({
  bool? useEnv,
  Map<String, Object?>? serviceAccountMap,
}) async {
  Map<String, Object?> serviceAccountFromString(String jsonString) {
    return (jsonDecode(jsonString) as Map).cast<String, Object?>();
  }

  var serviceAccountJsonOrPath = _envGetServiceAccountJsonOrPath();
  if (serviceAccountJsonOrPath == null) {
    throw UnsupportedError(
        'Missing env TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT');
  }
  Future<Map<String, Object?>> serviceAccountFromPath(String path) async {
    try {
      var serviceAccountJsonString = await fs.file(path).readAsString();
      return serviceAccountFromString(serviceAccountJsonString);
    } catch (e) {
      throw (StateError('Cannot read $path'));
    }
  }

  Map<String, Object?> jsonData;
  if (serviceAccountMap != null) {
    jsonData = serviceAccountMap;
  } else if (useEnv == true) {
    var serviceAccountJsonOrPath = _envGetServiceAccountJsonOrPath();
    if (serviceAccountJsonOrPath == null) {
      throw (StateError('$_envServiceAccount not set'));
    }
    if (serviceAccountJsonOrPath.startsWith('{')) {
      jsonData = serviceAccountFromString(serviceAccountJsonOrPath);
    } else {
      jsonData = await serviceAccountFromPath(serviceAccountJsonOrPath);
    }
  } else {
    throw UnsupportedError('Need useEnv or serviceAccountMap');
  }
  return FirebaseNodeTestContext(serviceAccount: jsonData);
}

/// Test context
class FirebaseNodeTestContext {
  /// Service account
  final Map<String, Object?> serviceAccount;

  /// App options
  FirebaseAppOptions get appOptions =>
      firebaseNodeAppOptionsFromServiceAccountMap(serviceAccount);

  /// Constructor
  FirebaseNodeTestContext({required this.serviceAccount});
}

/// True if running on github
bool get runningOnGithub => platform.runningOnGithub;

/// stable
/// ubuntu-latest
bool isGithubActionsUbuntuAndDartStable() {
  return platform.environment['TEKARTIK_GITHUB_ACTIONS_DART'] == 'stable' &&
      (platform.environment['TEKARTIK_GITHUB_ACTIONS_OS']
              ?.startsWith('ubuntu') ??
          false);
}

/// Github actions prefix
final githubActionsPrefix =
    'ga_${platform.environment['TEKARTIK_GITHUB_ACTIONS_DART']}_${platform.environment['TEKARTIK_GITHUB_ACTIONS_OS']?.split('-').first}';
