import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase_emulator/src/emulator.dart';

import 'emulator_options.dart';

/// Service for managing Firebase emulators.
class FirebaseEmulatorService {
  /// The path to the Firebase project directory.
  final String path;

  /// Creates a new [FirebaseEmulatorService] for the project at [path].
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

  /// Starts the Firebase emulator with the given [options].
  ///
  /// Waits until all emulators are ready before returning.
  Future<FirebaseEmulator> start({FirebaseEmulatorOptions? options}) async {
    options ??= FirebaseEmulatorOptions();
    var projectId = options.projectId ?? await getProjectId();

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
        '${(options.debug ?? false) ? ' --debug' : ''}'
        ' emulators:start'
        '${(options.onlyFunctions ?? false) ? ' --only functions' : ''}',
      );

      await completer.future.timeout(const Duration(seconds: 10));

      return createEmulator(
        path: path,
        options: options,
        shell: shell,
        done: done,
        projectId: projectId,
      );
    } catch (e) {
      completer.safeCompleteError(e);
      shell.kill(ProcessSignal.sigkill);
      rethrow;
    }
  }
}
