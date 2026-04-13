@TestOn('vm')
library;

import 'dart:async';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_node_build/gcf_build.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/import_common.dart';
import 'package:test/test.dart';

var defaultRegion = regionUsCentral1;
String buildFolder = join('build', 'tekartik_firebase_function_node');

Future main() async {
  //var httpClientFactory = httpClientFactoryIo;

  final firebaseInstalled = whichSync('firebase') != null;
  group(
    'firebase_functions_node',
    () {
      Future<FirebaseEmulator> startServer() async {
        var emulatorService = FirebaseEmulatorService(path: 'deploy');
        var emulator = await emulatorService.start(
          options: FirebaseEmulatorOptions(onlyFunctions: true, debug: false),
        );

        return emulator;
      }

      FirebaseEmulator? emulator;
      setUpAll(() async {
        await gcfNodePackageBuild('.');
        emulator = await startServer();
      });

      test('emulator', () async {
        expect(emulator, isNotNull);
      });
      test('helloWorldV1', () async {
        if (emulator != null) {
          var result = await read(
            Uri.parse(
              'http://127.0.0.1:5001/${emulator!.projectId}/$defaultRegion/thelloworldv1',
            ),
          );
          print(result);
        }
      }, skip: false);

      test('helloWorldV2', () async {
        if (emulator != null) {
          var result = await read(
            Uri.parse(
              'http://localhost:5001/${emulator!.projectId}/$regionBelgium/thelloworldv2',
            ),
          );
          print(result);
        }
      }, skip: false);

      /*TODO temp excluded
      common.main(
          testContext: FirebaseFunctionsTestContext(
              httpClientFactory: httpClientFactory),
          httpClientFactory: httpClientFactory,
          baseUrl: context.baseUrl);

       */
      tearDownAll(() async {
        print('stopping emulator');
        await emulator?.stop();
      });
    },
    skip: !firebaseInstalled,
    timeout: Timeout(Duration(minutes: 5)),
  );
}
