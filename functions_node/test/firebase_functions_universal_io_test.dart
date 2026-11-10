@TestOn('vm')
library;

import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:test/test.dart';

void main() {
  test(
    'functions(app) is one instance per app, serving its functions',
    () async {
      var app = newFirebaseAppLocal(
        options: FirebaseAppOptions(projectId: 'universal_io_test'),
      );
      var service = firebaseFunctionsServiceUniversal;
      var functions = service.functions(app);
      expect(service.functions(app), same(functions));
      functions['hello'] = functions.https.onRequest(
        (request) => request.response.send('hello'),
      );
      var server = await service.functions(app).serve(port: 0);
      var client = httpClientFactoryIo.newClient();
      try {
        var response = await client
            .get(server.uri.replace(path: 'hello'))
            .timeout(const Duration(seconds: 10));
        expect(response.statusCode, 200);
        expect(response.body, 'hello');
      } finally {
        client.close();
        await server.close();
        await app.delete();
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
