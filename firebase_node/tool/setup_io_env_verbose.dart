// ignore_for_file: avoid_print

import 'package:tekartik_build_node/build_node.dart';

/// Compiles and runs `tool/src/setup_env_verbose.dart` on node: it calls
/// `setupOrNull(useEnv: true, verbose: true)`, printing each step of the setup
/// and the resulting context (never the private key).
///
/// The setup uses TEKARTIK_FIREBASE_NODE_TEST_SERVICE_ACCOUNT (json or path),
/// so run it like the tests, i.e. from this package (`.local/ds_env.yaml`) or
/// with the variable set.
///
/// Node only as the setup imports the firebase admin js interop, this io
/// script only drives it.
var input = 'tool/src/setup_env_verbose.dart';
var output = 'build/tool/setup_env_verbose.js';

Future<void> main() async {
  await nodePackageCompileJs('.', input: input, output: output);
  await nodePackageRun('.', jsFile: output);
}
