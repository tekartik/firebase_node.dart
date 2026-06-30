import 'dart:io';

import 'package:dev_build/package.dart';
import 'package:dev_build/shell.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/map_utils.dart';
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

  static final _minFirebaseAdminVersion = Version(13, 8, 0);
  static final _minFirebaseFunctionsVersion = Version(7, 2, 5);
  static final _minFirebaseCliVersion = Version(15, 14, 0);

  var _lastStatusOk = false;

  /// Check if emulator is supported
  Future<bool> isSupported({bool? force}) async {
    return _checkIsSupported(force: force);
  }

  /// Check if emulator is supported
  Future<bool> _checkIsSupported({bool? force, bool? doThrow}) async {
    if (_lastStatusOk && force != true) {
      return true;
    }
    try {
      await _checkStatus();
      _lastStatusOk = true;
    } catch (e) {
      _lastStatusOk = false;
      if (doThrow == true) {
        rethrow;
      }
    }
    return _lastStatusOk;
  }

  Future<void> _checkStatus() async {
    // Check node settings in functions/package.json
    // min
    //   "engines": {
    //     "node": "22"
    //   },
    //   "main": "index.js",
    //   "dependencies": {
    //     "firebase-admin": "^13.8.0",
    //     "firebase-functions": "^7.2.5"
    //   },
    var functionsPackageJsonFile = File(
      p.join(path, 'functions', 'package.json'),
    );
    var firebaseVersion = Version.parse(
      (await run('firebase --version')).outText,
    );
    if (firebaseVersion < _minFirebaseCliVersion) {
      throw StateError('firebase-tools ^$_minFirebaseCliVersion expected');
    }
    if (functionsPackageJsonFile.existsSync()) {
      var map = parseJsonObject(await functionsPackageJsonFile.readAsString())!;
      var nodeVersion = parseInt(
        mapValueFromParts<Object>(map, ['engines', 'node']),
      );
      if (nodeVersion != null && nodeVersion < 20) {
        throw StateError('engines.node = 22+ expected');
      }
      var firebaseAdminBoundaries = mapValueFromParts<String>(map, [
        'dependencies',
        'firebase-admin',
      ]);
      if (firebaseAdminBoundaries != null) {
        var boundaries = VersionBoundaries.parse(firebaseAdminBoundaries);
        if (boundaries.min!.value < _minFirebaseAdminVersion) {
          throw StateError(
            'firebase-admin ^$_minFirebaseAdminVersion expected',
          );
        }
      }
      var firebaseFunctionsBoundaries = mapValueFromParts<String>(map, [
        'dependencies',
        'firebase-functions',
      ]);
      if (firebaseFunctionsBoundaries != null) {
        var boundaries = VersionBoundaries.parse(firebaseFunctionsBoundaries);
        if (boundaries.min!.value < _minFirebaseFunctionsVersion) {
          throw StateError(
            'firebase-functions ^$_minFirebaseFunctionsVersion expected',
          );
        }
      }
    }
  }

  Future<bool> _isEmulatorAuthRunning() async {
    return _isEmulatorRunning(host: 'localhost', port: 9099);
  }

  // ignore: unused_element
  Future<bool> _isEmulatorFirestoreRunning() async {
    return _isEmulatorRunning(host: 'localhost', port: 8080);
  }

  Future<bool> _isEmulatorRunning({
    String host = 'localhost',
    int port = 9099,
  }) async {
    final url = Uri.parse('http://$host:$port/');

    try {
      // We send a request to the emulator port.
      // Even if it returns a 404 (because the root path isn't a valid endpoint),
      // getting *any* HTTP response means the server is active and listening.
      await http.get(url).timeout(const Duration(milliseconds: 500));
      return true;
    } on SocketException {
      // A SocketException means connection refused -> Emulator is dead or not started.
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Starts the Firebase emulator with the given [options].
  ///
  /// Waits until all emulators are ready before returning.
  Future<FirebaseEmulator> start({FirebaseEmulatorOptions? options}) async {
    await _checkIsSupported(doThrow: true);
    options ??= FirebaseEmulatorOptions();
    var projectId = options.projectId ?? await getProjectId();

    var controller = ShellLinesController();
    var shell = Shell(
      options: ShellOptions(
        workingDirectory: path,
        stdout: controller.sink,
        verbose: true,
        mode: options.processStartMode,
      ),
    );
    var completer = Completer<bool>();
    controller.stream.listen((line) {
      stdout.writeln(line);
      if (line.contains('All emulators ready')) {
        completer.safeComplete(true);
      }
    });

    var onlyFunctions = options.onlyFunctions ?? false;
    var onlyAuth = options.onlyAuth ?? false;
    var onlyFirestore = options.onlyFirestore ?? false;
    var onlyStorage = options.onlyStorage ?? false;

    var only = onlyFunctions || onlyAuth || onlyFirestore || onlyStorage;

    if (await _isEmulatorAuthRunning() || await _isEmulatorFirestoreRunning()) {
      stderr.writeln(
        'Emulator is already running - try using it...not sure about its projectId...',
      );
      return FirebaseRunningEmulator(projectId: projectId);
    }

    var persistPath = options.persistPath;
    try {
      var done = shell.run(
        'firebase'
        ' --project $projectId'
        '${(options.debug ?? false) ? ' --debug' : ''}'
        ' emulators:start'
        '${only ? ' --only ${[if (onlyFunctions) 'functions', if (onlyAuth) 'auth', if (onlyFirestore) 'firestore', if (onlyStorage) 'storage'].join(',')}' : ''}'
        '${persistPath != null ? ' --import $persistPath --export-on-exit $persistPath' : ''}',
      );

      // 10 ok for node
      // 30 needed for dart
      await completer.future.timeout(const Duration(seconds: 30));

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
