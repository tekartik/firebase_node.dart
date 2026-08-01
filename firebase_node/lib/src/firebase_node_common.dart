import 'package:tekartik_common_utils/common_utils_import.dart';

/// Override from tests
bool _debugFirebaseNode = false;

/// Extra debug
@doNotSubmit
set debugFirebaseNode(bool debug) => _debugFirebaseNode = debug;

/// Extra debug
bool get debugFirebaseNode => _debugFirebaseNode;
