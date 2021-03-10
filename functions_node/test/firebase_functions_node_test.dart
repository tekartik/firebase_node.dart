@TestOn('vm')
library tekartik_firebase_functions_node.test.firebase_functions_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fs_shim/utils/io/copy.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:process_run/which.dart';
import 'package:tekartik_app_node_build/gcf_build.dart';
import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/travis/travis.dart';
import 'package:tekartik_firebase_functions_node/src/import.dart';
import 'package:tekartik_firebase_functions_test/firebase_functions_setup.dart';
import 'package:test/test.dart';

String buildFolder = join('build', 'tekartik_firebase_function_node');

@deprecated
Future<Process> firebaseBuildCopyAndServe({TestContext context}) async {
  await runCmd(
      PubCmd(['run', 'build_runner', 'build', '--output', 'bin:$buildFolder']));
  await copyFile(File(join(buildFolder, 'main.dart.js')),
      File(join('deploy', 'functions', 'index.js')));
  //var cmd = FirebaseCmd(
  //    firebaseArgs(serve: true, onlyFunctions: true, projectId: 'dev'));
  var completer = Completer<Process>();
  //print('firebase serve 1');
  //await Shell().cd('deploy').run('firebase serve');
  print('firebase serve');
  //await Shell().cd('deploy').run('firebase serve');

  var process = await Process.start(await which('firebase'), ['serve'],
      workingDirectory: 'deploy');
  process.stdout
      .transform(const Utf8Decoder())
      .transform(const LineSplitter())
      .listen((line) {
    // wait for the lines
    // +  functions: echo: http://localhost:5000/tekartik-free-dev/us-central1/echo
    // +  functions: echoFragment: http://localhost:5000/tekartik-free-dev/us-central1/echoFragment
    // +  functions: echoQuery: http://localhost:5000/tekartik-free-dev/us-central1/echoQuery
    print('serve $line');
    if (line.contains(url.join(context.baseUrl, 'echo'))) {
      if (!completer.isCompleted) {
        completer.complete(process);
      }
    }
  });
  process.stderr
      .transform(const Utf8Decoder())
      .transform(const LineSplitter())
      .listen((line) {
    print('error: $line');
  });
  unawaited(process.exitCode.then((exitCode) async {
    if (!completer.isCompleted) {
      //await stderr.addStream(process.stderr);
      print('exitCode: $exitCode');
      completer.completeError('exitCode: $exitCode');
    }
  }));

  return completer.future;
}

Future main() async {
  //var httpClientFactory = httpClientFactoryIo;

  var context = TestContext();

  context.baseUrl = 'http://localhost:5000/tekartik-free-dev/us-central1';

  final firebaseInstalled = whichSync('firebase') != null;
  group('firebase_functions_node', () {
    Future<void> testServe() async {
      var controller = ShellLinesController();
      var shell = Shell(stdout: controller.sink).cd('deploy');
      controller.stream.listen((line) {
        // out: === Serving from '/xxx//github.com/tekartik/firebase_functions.dart/firebase_functions_node/deploy'...
        // out: ✔  functions: Using node@10 from host.
        // out: i  functions: Watching "/xxx//github.com/tekartik/firebase_functions.dart/firebase_functions_node/deploy/functions" for Cloud Functions...
        // out: >  starting...
        // out: ✔  functions[helloWorld]: http function initialized (http://localhost:5000/xxx/us-central1/helloWorld).
        // out: >  serving...
        print('line: $line');
        if (line.contains('functions[helloWorld')) {
          shell.kill();
        }
      });
      try {
        await shell.run('firebase serve --only functions');
      } on ShellException catch (e) {
        print('Error $e');
      }
    }

    test('serve', () async {
      await testServe();
    }, skip: true); // manual experiment on serve only
    group('echo', () {
      Process process;
      setUpAll(() async {
        //process = await firebaseBuildCopyAndServe(context: context);
        await gcfNodeBuild();
        await gcfNodeCopyToDeploy();
      });

      test('serve', () async {
        await testServe();
      }, skip: false);

      /*TODO temp excluded
      common.main(
          testContext: FirebaseFunctionsTestContext(
              httpClientFactory: httpClientFactory),
          httpClientFactory: httpClientFactory,
          baseUrl: context.baseUrl);

       */
      tearDownAll(() async {
        // await server.close();
        process?.kill();
      });
    }, skip: !firebaseInstalled || runningInTravis);
  });
}

/// Basic shell lines controller.
///
/// Usage:
/// ```dart
/// ```
class ShellLinesController {
  final _controller = StreamController<List<int>>();

  /// The sink for the Shell stderr/stdout
  StreamSink<List<int>> get sink => _controller.sink;

  /// The stram to listen to
  Stream<String> get stream => streamLines(_controller.stream);
}

/// Basic line streaming. Assuming system encoding
Stream<String> streamLines(Stream<List<int>> stream,
    {Encoding encoding = systemEncoding}) {
  StreamSubscription subscription;
  List<int> currentLine;
  const endOfLine = 10;
  const lineFeed = 13;
  StreamController<String> ctlr;
  encoding ??= systemEncoding;
  ctlr = StreamController<String>(onListen: () {
    void addCurrentLine() {
      if (currentLine?.isNotEmpty ?? false) {
        try {
          ctlr.add(systemEncoding.decode(currentLine));
        } catch (_) {
          // Ignore nad encoded line
          print('ignoring: $currentLine');
        }
      }
      currentLine = null;
    }

    void addToCurrentLine(List<int> data) {
      if (currentLine == null) {
        currentLine = data;
      } else {
        var newCurrentLine = Uint8List(currentLine.length + data.length);
        newCurrentLine.setAll(0, currentLine);
        newCurrentLine.setAll(currentLine.length, data);
        currentLine = newCurrentLine;
      }
    }

    subscription = stream.listen((data) {
      // var _w;
      // print('read $data');
      // devPrint('read $data');
      // look for \n (10)
      var start = 0;
      for (var i = 0; i < data.length; i++) {
        var byte = data[i];
        if (byte == endOfLine || byte == lineFeed) {
          addToCurrentLine(data.sublist(start, i));
          addCurrentLine();
          // Skip it
          start = i + 1;
        }
      }
      // Store last current line
      if (data.length > start) {
        addToCurrentLine(data.sublist(start, data.length));
      }
    }, onDone: () {
      // Last one
      if (currentLine != null) {
        addCurrentLine();
      }
      ctlr.close();
    });
  }, onCancel: () {
    subscription?.cancel();
  });

  return ctlr.stream;
}
