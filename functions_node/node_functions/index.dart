import 'package:tekartik_firebase_functions/src/ff_server.dart';
import 'package:tekartik_firebase_functions_node/firebase_functions_node.dart';
import 'package:tekartik_firebase_functions_test/firebase_functions_setup.dart'
    as setup;
import 'package:tekartik_firebase_functions_test/firebase_functions_test.dart';
import 'package:tekartik_http_node/http_client_node.dart';

/// Memory for inner communication, http for outer
class FirebaseFunctionsTestContextNode extends FirebaseFunctionsTestContext {
  @override
  // ignore: overridden_fields
  final String baseUrl = 'http://localhost:5000/tekartik-free-dev/us-central1';

  FirebaseFunctionsTestContextNode({super.baseUrl})
      : super(
            httpClientFactory: httpClientFactoryNode,
            firebaseFunctions: firebaseFunctionsNode);

  @override
  Future<FfServer> serve() {
    // TODO: implement serve
    throw UnimplementedError();
  }

  @override
  String url(String path) {
    // TODO: implement url
    throw UnimplementedError();
  }
}

void main() async {
  var context = FirebaseFunctionsTestContextNode();
  context = setup.setup(testContext: context);

  await context.serve();
}
