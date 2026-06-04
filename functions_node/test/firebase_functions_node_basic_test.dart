@TestOn('vm')
library;

import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_app_node_build/gcf_build.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:tekartik_firebase_functions_call_http/functions_call_http.dart';
import 'package:tekartik_firebase_functions_node/firebase_functions_universal.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:tekartik_firebase_functions_test/firebase_functions_test_runner.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:test/test.dart';

var defaultRegion = regionUsCentral1;
String buildFolder = join('build', 'tekartik_firebase_function_node');
final emulatorService = FirebaseEmulatorService(path: 'deploy');
Future main() async {
  //var httpClientFactory = httpClientFactoryIo;

  final emulatorSupported = await emulatorService.isSupported();
  if (!emulatorSupported) {
    return;
  }
  late FirebaseEmulator emulator;
  Future<void> buildAndStartEmulator() async {
    Future<FirebaseEmulator> startServer() async {
      var emulator = await emulatorService.start(
        options: FirebaseEmulatorOptions(onlyFunctions: true, debug: false),
      );
      return emulator;
    }

    await gcfNodePackageBuild('.');
    emulator = await startServer();
  }

  late FirebaseFunctionsTestClientContext testContext;
  setUpAll(() async {
    // ignore: avoid_print
    await buildAndStartEmulator();
    var projectId = emulator.projectId;
    var app = newFirebaseAppLocal(
      options: FirebaseAppOptions(projectId: projectId),
    );
    var prefix = 'node';

    var firebaseFunctionsCall = firebaseFunctionsCallServiceHttp.functionsCall(
      app,
      options: FirebaseFunctionsCallOptions(region: regionBelgium),
    );

    testContext = FirebaseFunctionsTestClientContext.urlTemplate(
      httpClientFactory: httpClientFactoryIo,
      urlTemplate:
          'http://localhost:5001/${emulator.projectId}/$regionBelgium/$prefix{{function}}',
      functionsCall: firebaseFunctionsCall,
    );
  });
  basicTestGroup(() => testContext);
  tearDownAll(() async {
    // ignore: avoid_print
    print('stopping emulator');
    try {
      await emulator.stop();
    } catch (_) {}
  });
  /*
  group('firebase_functions_node', () {
    test('emulator', () async {
      expect(emulator, isNotNull);
    });
    test('helloWorldV1', () async {
      var result = await read(
        Uri.parse(
          'http://127.0.0.1:5001/${emulator.projectId}/$defaultRegion/thelloworldv1',
        ),
      );
      // ignore: avoid_print
      print(result);
    }, skip: false);

    test('helloWorldV2', () async {
      var result = await read(
        Uri.parse(
          'http://localhost:5001/${emulator.projectId}/$regionBelgium/thelloworldv2',
        ),
      );
      // ignore: avoid_print
      print(result);
    });

    /*TODO temp excluded
      common.main(
          testContext: FirebaseFunctionsTestContext(
              httpClientFactory: httpClientFactory),
          httpClientFactory: httpClientFactory,
          baseUrl: context.baseUrl);

       */
  }, timeout: Timeout(Duration(minutes: 5)));*/
}
