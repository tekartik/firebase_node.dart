import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_auth_node/src/node/auth_node.dart'
    as auth_node;

AuthService get authServiceNode => auth_node.authService;

@Deprecated('Use authServiceNode')
AuthService get authService => authServiceNode;
