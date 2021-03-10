import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_node_build/gcf_build.dart';
import 'package:process_run/shell_run.dart';

String buildFolder =
    join('.dart_tool', 'tekartik_firebase_function_node', 'build');

Future main() async {
  await build();
}

Future build() async {
  var shell = Shell();

  await shell.run('''
pub run build_runner build --output node_functions:$buildFolder
''');
  await File(join(buildFolder, 'index.dart.js'))
      .copy('deploy/functions/index.js');
  await gcfNodeServe();
}
