import 'package:tekartik_build_node/build_node.dart';

Future main() async {
  //print(Map.from(shellEnvironment));
  await nodePackageRunTest('.', testFiles: ['test/firestore_node_test.dart']);
}
