import 'package:process_run/shell_run.dart';
import 'package:tekartik_app_node_build/gcf_build.dart';

Future main() async {
  await gcfNodeBuild();
  //await gcfNodeServe();
  var shell = Shell(workingDirectory: 'deploy');
  await shell.run('firebase serve --only functions:command');
}
