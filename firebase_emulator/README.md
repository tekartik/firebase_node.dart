# tekartik_firebase_emulator

Start, query and stop the Firebase emulator suite (auth, firestore, storage,
functions, pubsub, hosting) of a firebase folder from Dart: tool scripts and
tests. It is the light entry point of the implementation living in
[tekartik_firebase_tools_common](https://github.com/tekartik/firebase_tools.dart/tree/master/packages/firebase_tools_common)
(no admin sdk behind it, a Flutter app can depend on it for its tests).

Dart VM only (`dart:io`, Linux, macOS, Windows): it runs the `firebase` cli
(15.14 or newer, `npm install -g firebase-tools`).

## Getting started

A git dependency (not on pub.dev), usually a dev dependency:

```yaml
dev_dependencies:
  tekartik_firebase_emulator:
    git:
      url: https://github.com/tekartik/firebase_node.dart
      path: firebase_emulator
```

A firebase folder, `deploy/` here, holds:

- `firebase.json` with an `emulators` section (the ports: auth 9099,
  firestore 8080, storage 9199, functions 5001; `"ui": {"enabled": true}`);
- `.firebaserc`, `{"projects": {"default": "demo-my-app"}}`: a `demo-`
  project id needs no credentials and never reaches a real project.

A test starting its own auth emulator:

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_emulator/firebase_emulator.dart';
import 'package:test/test.dart';

var service = FirebaseEmulatorService(path: 'deploy');

Future<void> main() async {
  var options = FirebaseEmulatorOptions(
    projectId: 'demo-my-app',
    onlyAuth: true,
  );
  if (!await service.isSupported(options: options)) {
    test('auth emulator', () {}, skip: 'firebase emulator not supported');
    return;
  }
  group('auth emulator', () {
    late FirebaseEmulator emulator;
    setUpAll(() async {
      emulator = await service.start(options: options);
    });
    tearDownAll(() async {
      await emulator.stop();
    });
    test('running', () async {
      var status = await service.checkStatus();
      expect(status.running, isTrue);
    });
  }, timeout: const Timeout(Duration(minutes: 5)));
}
```

The clients then reach `localhost:9099`, `localhost:8080`... set the emulator
hosts in the process environment (`FIREBASE_AUTH_EMULATOR_HOST`,
`FIRESTORE_EMULATOR_HOST`...) for the libraries that read them.

## What to use

| Api | Does |
| --- | --- |
| `FirebaseEmulatorService(path:)` | one per firebase folder |
| `isSupported(options:)` | false without the cli or the `.firebaserc`, or when a running hub lacks a requested service |
| `checkStatus()` | `EmulatorServiceRunningStatus` (the ports served), `...NotRunningStatus` or `...NotSupportedStatus` |
| `start(options:, timeout:)` | `firebase emulators:start`, returns once `All emulators ready` is printed (180 s by default) |
| `FirebaseEmulatorOptions` | `projectId` (else the `.firebaserc` one), `only*` services, `persistPath` (import and export on exit), `debug` |
| `FirebaseEmulator.stop()` | interrupts the cli, waits for it to exit (killed after 30 s), releases the lock |

## Pitfalls

- `start` holds a machine wide lock (`firebaseEmulatorLockName`) until
  `stop`, even when it reuses a running hub (a `FirebaseRunningEmulator`):
  another test file or process waits for it (10 minutes at most). Always
  `stop`, and keep `concurrency: 1` in `dart_test.yaml`.
- A real project id (`projectId`, or the `.firebaserc` default) lets the
  functions the emulator runs reach, in production, the services that are not
  emulated. Tests and samples use a `demo-` id.
- An emulator hub already running on `localhost:4400` is reused when it serves
  the requested `only*` services; with no `only*` nothing is checked.
- `processStartMode` must keep the output piped (the default):
  `start` waits for the `All emulators ready` line on the cli output, with
  `ProcessStartMode.inheritStdio` it never sees it, times out and kills the
  cli.
- `persistPath` (`.data`) is imported at start and exported on exit: keep it
  out of source control.

The agent skill of this package: `skills/tekartik-firebase-emulator-setup`.
