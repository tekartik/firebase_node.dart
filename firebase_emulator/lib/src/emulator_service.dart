import 'dart:io';

import 'package:dev_build/package.dart';
import 'package:dev_build/shell.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/map_utils.dart';
import 'package:tekartik_firebase_emulator/src/emulator.dart';

import 'emulator_options.dart';

/// Represents the status of the Firebase emulator service.
abstract class EmulatorServiceStatus {
  /// Whether the emulator service is currently running.
  bool get running => false;

  /// Whether the emulator service is supported.
  bool get supported => false;
}

/// Status indicating that the Firebase emulator service is not running.
class EmulatorServiceNotRunningStatus implements EmulatorServiceStatus {
  @override
  bool get running => false;

  @override
  bool get supported => true;

  @override
  String toString() {
    return 'EmulatorServiceNotRunningStatus()';
  }
}

/// Status indicating that the Firebase emulator service is not supported.
class EmulatorServiceNotSupportedStatus implements EmulatorServiceStatus {
  @override
  bool get running => false;

  @override
  bool get supported => false;

  @override
  String toString() {
    return 'EmulatorServiceNotSupportedStatus()';
  }
}

/// Status indicating that the Firebase emulator service is running.
class EmulatorServiceRunningStatus implements EmulatorServiceStatus {
  @override
  bool get running => true;

  /// The port on which the Firestore emulator is running, if active.
  final int? firestorePort;

  /// The port on which the Auth emulator is running, if active.
  final int? authPort;

  /// The port on which the Storage emulator is running, if active.
  final int? storagePort;

  /// The port on which the Functions emulator is running, if active.
  final int? functionsPort;

  /// Creates a new [EmulatorServiceRunningStatus] with the specified emulator ports.
  EmulatorServiceRunningStatus({
    required this.firestorePort,
    required this.authPort,
    required this.storagePort,
    required this.functionsPort,
  });

  @override
  String toString() {
    return 'EmulatorServiceRunningStatus(firestorePort: $firestorePort, authPort: $authPort, storagePort: $storagePort, functionsPort: $functionsPort)';
  }

  @override
  bool get supported => true;
}

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

  /// Default emulator hub port.
  static const _hubPort = 4400;

  /// Get the running emulator services (service name to port) by querying
  /// the emulator hub at `localhost:4400/emulators`.
  ///
  /// Returns null if the hub is not running.
  Future<Map<String, int>?> _getRunningServices() async {
    final url = Uri.parse('http://localhost:$_hubPort/emulators');
    try {
      var response = await http
          .get(url)
          .timeout(const Duration(milliseconds: 500));
      if (response.statusCode != 200) {
        return null;
      }
      var map = parseJsonObject(response.body)!;
      var services = <String, int>{};
      for (var service in map.keys) {
        var port = parseInt(mapValueFromParts<Object>(map, [service, 'port']));
        if (port != null) {
          services[service] = port;
        }
      }
      return services;
    } catch (_) {
      return null;
    }
  }

  /// Check status
  Future<EmulatorServiceStatus> checkStatus({bool? force}) async {
    if (!(await _checkIsSupported(force: force))) {
      return EmulatorServiceNotSupportedStatus();
    }
    var runningServices = await _getRunningServices();
    if (runningServices == null) {
      return EmulatorServiceNotRunningStatus();
    }
    return EmulatorServiceRunningStatus(
      firestorePort: runningServices['firestore'],
      authPort: runningServices['auth'],
      storagePort: runningServices['storage'],
      functionsPort: runningServices['functions'],
    );
  }

  /// Check if emulator is supported.
  ///
  /// Returns false if `.firebaserc` is not present in [path].
  ///
  /// If an emulator is already running (hub found on localhost:4400), returns
  /// true only if all the services requested in [options] are running.
  Future<bool> isSupported({
    bool? force,
    FirebaseEmulatorOptions? options,
  }) async {
    var status = await checkStatus(force: force);
    if (!status.supported) {
      return false;
    }
    if (status.running) {
      var running = status as EmulatorServiceRunningStatus;
      if ((options?.onlyFunctions ?? false) && running.functionsPort == null) {
        stderr.writeln('Emulator is running but functions is not running');
        return false;
      }
      if ((options?.onlyAuth ?? false) && running.authPort == null) {
        stderr.writeln('Emulator is running but auth is not running');
        return false;
      }
      if ((options?.onlyFirestore ?? false) && running.firestorePort == null) {
        stderr.writeln('Emulator is running but firestore is not running');
        return false;
      }
      if ((options?.onlyStorage ?? false) && running.storagePort == null) {
        stderr.writeln('Emulator is running but storage is not running');
        return false;
      }
    }
    return _checkIsSupported(force: force);
  }

  /// Check if emulator is supported
  Future<bool> _checkIsSupported({bool? force, bool? doThrow}) async {
    if (_lastStatusOk && force != true) {
      return true;
    }
    try {
      await _checkSetup();
      _lastStatusOk = true;
    } catch (e) {
      _lastStatusOk = false;
      if (doThrow == true) {
        rethrow;
      }
    }
    return _lastStatusOk;
  }

  // throw on error
  Future<void> _checkSetup() async {
    /// Global installation
    var firebaseVersion = Version.parse(
      (await run('firebase --version')).outText,
    );
    if (firebaseVersion < _minFirebaseCliVersion) {
      throw StateError('firebase-tools ^$_minFirebaseCliVersion expected');
    }

    var firebaseRcFile = File(p.join(path, '.firebaserc'));
    if (!firebaseRcFile.existsSync()) {
      throw UnsupportedError(
        'Firebase emulator not supported: .firebaserc not found in $path',
      );
    }
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

    if (functionsPackageJsonFile.existsSync()) {
      // Node test
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
    return _isEmulatorPortRunning(host: 'localhost', port: 9099);
  }

  Future<bool> _isEmulatorStorageRunning() async {
    return _isEmulatorPortRunning(host: 'localhost', port: 9199);
  }

  // ignore: unused_element
  Future<bool> _isEmulatorFirestoreRunning() async {
    return _isEmulatorPortRunning(host: 'localhost', port: 8080);
  }

  Future<bool> _isEmulatorRunning() async {
    var futures = [
      _isEmulatorAuthRunning(),
      _isEmulatorFirestoreRunning(),
      _isEmulatorStorageRunning(),
    ];
    var results = await Future.wait(futures);
    return results.contains(true);
  }

  Future<bool> _isEmulatorPortRunning({
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

    if (await _isEmulatorRunning()) {
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
