import 'package:path/path.dart';
import 'package:tekartik_app_node_build/package.dart';

var topDir = '..';

Future<void> main() async {
  for (var dir in [
    'storage_node',
    'functions_node',
    'firestore_node',
    'firebase_node',
    'auth_node',
  ]) {
    var path = join(topDir, dir);
    print('# dir');
    await nodePackageRunCi(path);
  }
}
