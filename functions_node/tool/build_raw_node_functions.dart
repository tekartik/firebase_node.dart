import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';

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
}
