
import 'package:tekartik_app_node_build/gcf_build.dart';

var options = GcfNodeAppOptions(functions: ['command'], deployDir: 'deploy');
var builder = GcfNodeAppBuilder(options: options);
Future main() async {
  await builder.buildAndServe();
}
