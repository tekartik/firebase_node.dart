import 'package:dev_test/package.dart';

import 'build_bin.dart';

Future main() async {
  await packageRunCi('.');
  /*
  var shell = Shell();

  await shell.run('''
  # Analyze code
  dartanalyzer --fatal-warnings --fatal-infos lib test tool node_functions
  dartfmt -n --set-exit-if-changed lib test tool node_functions

  pub run test -p vm
''');
  */
  await build();
}
