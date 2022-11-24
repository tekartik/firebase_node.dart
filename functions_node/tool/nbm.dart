import 'package:http/http.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_node_build_menu/app_build_menu.dart';
import 'package:tekartik_app_node_build_menu/src/bin/nbm.dart';

var env = ShellEnvironment();
var projectId = 'tekartik-eu-dev'; //env.
Future<void> main(List<String> arguments) async {
  menu('config', () {
    item('projectId', () {});
  });
  gcfMenuAppContent(
      options: GcfNodeAppOptions(
          projectId: projectId,
          deployDir: 'deploy',
          functions: ['helloWorld', 'helloCall']));
  nbm(arguments);
  menu('rest_test', () async {
    item('helloWorld', () async {
      var hello = await read(Uri.parse(
          'https://europe-west1-tekartik-eu-dev.cloudfunctions.net/helloWorld'));
      print(hello);
    });
  });
}
