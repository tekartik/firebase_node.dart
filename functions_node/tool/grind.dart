import 'package:grinder/grinder.dart';
import 'package:tekartik_build_utils/common_import.dart';

import '../test/firebase_functions_node_test.dart';

// ignore_for_file: non_constant_identifier_names
Future main(List<String> args) => grind(args);

@Task()
Future test() => TestRunner().testAsync();

@Depends(test)
void build() {
  Pub.build();
}

String projectIdDev = 'tekartik-free-dev';
String projectId = projectIdDev;

@DefaultTask()
Future firebase_serve() async {
  await runCmd(PubCmd([
    'run',
    'build_runner',
    'build',
    '--output',
    'node_functions:$buildFolder'
  ]));
  copy(File(join(buildFolder, 'index.dart.js')), Directory('functions'));
  await runCmd(FirebaseCmd(firebaseArgs(serve: true, onlyFunctions: true)));
}

@Task()
void clean() => defaultClean();

@Task()
Future build_test() async {
  //await Pub.build(directories: [binDir.path]);
  await runCmd(PubCmd(
      pubRunArgs(['build_runner', 'build', '--output', 'test:build/test'])));
  //await copy_build();
}

@Task()
Future watch() async {
  await runCmd(PubCmd(
      pubRunArgs(['build_runner', 'watch', '--output', 'test:build/test'])));
}
