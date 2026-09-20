---
name: tekartik-firebase-emulator-setup
description: >-
  Use when a dart tool script or test must start, query or stop the Firebase
  emulator suite (auth, firestore, storage, functions, pubsub) of a firebase
  folder with tekartik_firebase_emulator: FirebaseEmulatorService
  (isSupported, checkStatus, getProjectId, start), FirebaseEmulatorOptions
  (onlyAuth, onlyFirestore, onlyStorage, onlyFunctions, onlyPubsub,
  persistPath, debug, processStartMode), FirebaseEmulator.stop and
  FirebaseRunningEmulator, EmulatorServiceStatus / EmulatorServiceRunningStatus
  and the emulator ports, the deploy/ folder with firebase.json and
  .firebaserc, and skipping tests when the emulators are not available.
---

# tekartik_firebase_emulator: the firebase emulator suite from dart

`tekartik_firebase_emulator` drives `firebase emulators:start` for one firebase
folder and asks the emulator hub (`localhost:4400`) what is running. It is the
lightweight entry point of the implementation living in
`tekartik_firebase_tools_common`
(`package:tekartik_firebase_tools_common/firebase_emulator.dart`, re-exported
whole): no admin sdk behind it, so a flutter app can depend on it for its tests
and tool scripts; `tekartik_firebase_tools` adds the dev menus around it. Pure
dart, VM only (`dart:io`, the `firebase` cli).

## Guidelines

* Dependency (git, not on pub.dev; usually a `dev_dependency`, it serves
  `tool/` scripts and tests):
  ```yaml
  dev_dependencies:
    tekartik_firebase_emulator:
      git:
        url: https://github.com/tekartik/firebase_node.dart
        path: firebase_emulator
  ```
  Import `package:tekartik_firebase_emulator/firebase_emulator.dart`.
* Requirements: the firebase cli 15.14+ on the path
  (`npm install -g firebase-tools`) and a firebase folder (`deploy/` in this
  repository) holding `firebase.json` (an `emulators` section with the ports
  and `"ui": {"enabled": true}`) and `.firebaserc`
  (`{"projects": {"default": "<project-id>"}}`, written by `firebase use
  --add`; a `demo-` project id needs no credentials). When
  `functions/package.json` exists in that folder it must declare node 20+,
  `firebase-admin` 13.8+ and `firebase-functions` 7.2.5+.
* `FirebaseEmulatorService(path: 'deploy')`: one per firebase folder, as a
  top-level variable. `await service.isSupported(options:)` is the guard: false
  without the cli or the `.firebaserc`, and when emulators already run but not
  every service `options` asks for; the cause is not returned, so print what
  is needed. `await service.getProjectId()` reads the default project
  (`firebase -j use`).
* `await service.checkStatus(force:, verbose:)` returns an
  `EmulatorServiceStatus` (`running`, `supported`):
  `EmulatorServiceNotSupportedStatus`, `EmulatorServiceNotRunningStatus` or
  `EmulatorServiceRunningStatus` with the `authPort`, `firestorePort`,
  `storagePort`, `functionsPort` and `pubsubPort` actually served (`null` when
  that emulator is down). `verbose: true` prints the hub answer, `force: true`
  re-runs the setup checks.
* `var emulator = await service.start(options:, timeout:)` runs
  `firebase --project <id> emulators:start [--only ...] [--import p
  --export-on-exit p] [--debug]` in the folder, echoes its output and returns
  a `FirebaseEmulator` once `All emulators ready` is printed (180 s default
  timeout, raise it for slow function builds; on timeout the process is
  killed and the error rethrown). If a hub already runs with every requested
  service, nothing is started and a `FirebaseRunningEmulator` comes back,
  whose `stop()` does nothing (test `emulator is FirebaseRunningEmulator`
  when a script must say so). `emulator.projectId`, `path` and `options`
  describe the run.
* `FirebaseEmulatorOptions`: `projectId` (else `.firebaserc`), `onlyAuth`,
  `onlyFirestore`, `onlyStorage`, `onlyFunctions`, `onlyPubsub` (combine them
  for `--only auth,firestore`; none means every emulator of `firebase.json`),
  `debug`, `persistPath` (`.data` here: imported at start, exported on exit,
  keep it out of source control), `processStartMode`
  (`ProcessStartMode.inheritStdio` for the cli's interactive output, not from
  an IDE run configuration). `copyWith(...)` derives a variant.
* Always `await emulator.stop()` (sigint, then waits for the process): in a
  `tearDownAll`, or after a prompt in a tool script (`prompt` and
  `promptTerminate` from `package:dev_build/shell.dart`). From a terminal
  Ctrl+C also reaches the `firebase` child.
* Tests: `@TestOn('vm')`, `concurrency: 1` in `dart_test.yaml` (one emulator
  at a time, same ports), a `Timeout(Duration(minutes: 5))` on the group; skip
  rather than fail when `isSupported()` is false. Ports of this repository's
  `firebase.json`: auth 9099, firestore 8080, storage 9199, functions 5001,
  ui 4000, hub 4400; keep them in one dart constant file shared by the app,
  the tests and the scripts.

## Examples

### tool/start_emulator.dart

```dart
import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

var service = FirebaseEmulatorService(path: 'deploy');

Future<void> main() async {
  if (!await service.isSupported()) {
    stderr.writeln(
      'firebase emulator not supported: firebase cli 15.14+ and '
      'deploy/.firebaserc needed',
    );
    exit(1);
  }
  var emulator = await service.start(
    options: FirebaseEmulatorOptions(
      onlyAuth: true,
      onlyFirestore: true,
      persistPath: '.data',
    ),
  );
  if (emulator is FirebaseRunningEmulator) {
    stdout.writeln('emulators already running');
    return;
  }
  stdout.writeln('Emulator started (project ${emulator.projectId})');
  await prompt('Press enter to stop the emulator');
  await emulator.stop();
  stdout.writeln('Emulator stopped');
  await promptTerminate();
}
```

### Dump what is running

```dart
import 'dart:io';

import 'package:tekartik_firebase_emulator/firebase_emulator.dart';

Future<void> main() async {
  var service = FirebaseEmulatorService(path: 'deploy');
  var status = await service.checkStatus(verbose: true);
  if (status is EmulatorServiceRunningStatus) {
    stdout.writeln(
      'auth ${status.authPort}, firestore ${status.firestorePort}, '
      'storage ${status.storagePort}, functions ${status.functionsPort}, '
      'pubsub ${status.pubsubPort}',
    );
  } else {
    stdout.writeln('not running (supported: ${status.supported})');
  }
}
```

### Test starting its own auth emulator

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:test/test.dart';

var service = FirebaseEmulatorService(path: 'deploy');

Future<void> main() async {
  var options = FirebaseEmulatorOptions(onlyAuth: true, debug: false);
  if (!await service.isSupported(options: options)) {
    test('not supported', () {}, skip: 'firebase emulator is not supported');
    return;
  }
  group('auth emulator', () {
    late FirebaseEmulator emulator;
    setUpAll(() async {
      emulator = await service.start(options: options);
    });
    test('auth port', () async {
      var status = await service.checkStatus() as EmulatorServiceRunningStatus;
      expect(status.authPort, 9099);
    });
    tearDownAll(() async {
      await emulator.stop();
    });
  }, timeout: const Timeout(Duration(minutes: 5)));
}
```

### Test skipped when the emulators are down (never starts them)

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var status = await FirebaseEmulatorService(path: 'deploy').checkStatus();
  if (status is! EmulatorServiceRunningStatus || status.firestorePort == null) {
    test(
      'firestore emulator',
      () {},
      skip: 'start it with `dart run tool/start_emulator.dart`',
    );
    return;
  }
  test('firestore on localhost:${status.firestorePort}', () async {
    // point the firestore client at localhost:${status.firestorePort} here
  });
}
```

## Common mistakes

* No `.firebaserc` in the folder: `isSupported()` is false and `start`
  throws even with `projectId` given.
* Forgetting `emulator.stop()`: the `firebase` process outlives the test run
  and the next `start` finds a hub with the wrong services.
* Two test files starting emulators concurrently: set `concurrency: 1`.
* Committing `.data` (the `persistPath` export).
