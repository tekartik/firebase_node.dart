import 'package:tekartik_app_node_build/gcf_build.dart';

Future main() async {
  //await gcfNodeCopyToDeploy();
  await gcfNodeServe();
  //var shell = Shell(workingDirectory: 'deploy');
  //await shell.run('firebase emulators:start --only functions:command');
}
