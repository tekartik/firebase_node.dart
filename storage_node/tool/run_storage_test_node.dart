import 'package:tekartik_build_node/build_node.dart';

Future main() async {
  await nodePackageRunTest('.', testFiles: ['test/storage_node_test.dart']);
}
