import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_auth_node/src/node_legacy/auth_node_legacy.dart'
    as auth_node;

AuthService get authServiceNode => auth_node.authService;
AuthService get authService => authServiceNode;
