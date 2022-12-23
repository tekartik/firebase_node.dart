import 'dart:async';

import 'package:tekartik_app_node_build/gcf_build.dart';

// Make sure to deploy storage before
Future main() async {
  await gcfNodePackageServeFunctions('.');
}
