@TestOn('vm')
library;

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_node_build/gcf_build.dart';
import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/node_legacy/import.dart';
import 'package:test/test.dart';

var defaultRegion = regionUsCentral1;
String buildFolder = join('build', 'tekartik_firebase_function_node');

Future main() async {
  //var httpClientFactory = httpClientFactoryIo;

  final firebaseInstalled = whichSync('firebase') != null;
  group('firebase_functions_node', () {
    Future<Shell> startServer() async {
      var controller = ShellLinesController();
      var shell = Shell(stdout: controller.sink).cd('deploy');
      var completer = Completer<Shell>();
      controller.stream.listen((line) {
        // out: === Serving from '/xxx//github.com/tekartik/firebase_functions.dart/firebase_functions_node/deploy'...
        // out: ✔  functions: Using node@10 from host.
        // out: i  functions: Watching "/xxx//github.com/tekartik/firebase_functions.dart/firebase_functions_node/deploy/functions" for Cloud Functions...
        // out: >  starting...
        // out: ✔  functions[helloWorld]: http function initialized (http://localhost:5000/xxx/us-central1/helloWorld).
        // out: >  serving...
        print('line: $line');
        if (line.contains('$defaultRegion/helloWorld')) {
          if (!completer.isCompleted) {
            completer.complete(shell);
          }
        }
      });

      () async {
        try {
          await shell.run('firebase serve --only functions');
        } on ShellException catch (e) {
          print('Error $e');
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      }()
          .unawait();
      return completer.future;
    }

    group('serve', () {
      String? projectId;
      Shell? shell;
      setUpAll(() async {
        print('hola');
        try {
          var lines =
              (await Shell(workingDirectory: 'deploy').run('firebase use'))
                  .outLines;
          // Project on the first line !
          // either: Active Project: xxxxxx
          // or: xxxxxx
          var line = lines.first;
          projectId = line.split(' ').last;

          if (projectId != null) {
            await gcfNodePackageBuild('.');
            shell = await startServer();
          }
        } catch (_) {}
        if (projectId != null) {}
      });

      test('helloWorldV1', () async {
        if (projectId != null) {
          var result = await read(Uri.parse(
              'http://localhost:5000/$projectId/$defaultRegion/helloWorld'));
          print(result);
        }
      }, skip: false);

      test('helloWorldV2', () async {
        if (projectId != null) {
          var result = await read(Uri.parse(
              'http://localhost:5000/$projectId/$defaultRegion/helloworldv2'));
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
        shell?.kill();
      });
    }, skip: !firebaseInstalled, timeout: Timeout(Duration(minutes: 5)));
  });
}
