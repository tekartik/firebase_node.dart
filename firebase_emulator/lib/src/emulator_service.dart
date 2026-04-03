import 'dart:async';
import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase_emulator/src/emulator.dart';

import 'emulator_options.dart';

class FirebaseEmulatorService {
  final String path;

  FirebaseEmulatorService({required this.path});

  /// Extract from .firebaserc
  Future<String> getProjectId({bool? verbose}) async {
    // {
    //   "status": "success",
    //   "result": "my_project_id"
    // }
    try {
      var map =
          jsonDecode(
                (await Shell(
                  verbose: verbose ?? false,
                  workingDirectory: path,
                ).run('firebase -j use')).outText,
              )
              as Map;
      return map['result'] as String;
    } catch (e) {
      stderr.writeln('Error getting project id: $e');
      stderr.writeln('In folder $path, run `firebase init');
      rethrow;
    }
  }

  Future<FirebaseEmulator> start({FirebaseEmulatorOptions? options}) async {
    var projectId = options?.projectId ?? await getProjectId();
    options ??= FirebaseEmulatorOptions(projectId: projectId);
    var controller = ShellLinesController();
    var shell = Shell(
      workingDirectory: path,
      stdout: controller.sink,
      verbose: true,
    );
    var completer = Completer<bool>();
    controller.stream.listen((line) {
      stdout.writeln(line);
      if (line.contains('All emulators ready')) {
        completer.safeComplete(true);
      }
    });

    try {
      var done = shell.run(
        'firebase'
        ' --project $projectId'
        ' emulators:start'
        '${options.onlyFunctions != null ? ' --only functions' : ''}',
      );

      await completer.future.timeout(const Duration(seconds: 10));

      return createEmulator(
        path: path,
        options: options,
        shell: shell,
        done: done,
      );
    } catch (e) {
      completer.safeCompleteError(e);
      shell.kill(ProcessSignal.sigkill);
      rethrow;
    }
  }
}
