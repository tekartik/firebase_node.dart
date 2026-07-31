/// Starting and querying the firebase emulator suite of a firebase folder.
///
/// Everything here now lives in `tekartik_firebase_tools_common`, which
/// aggregates it with the firebase project deploy commands and the
/// auth/firestore/storage explorer. This package is kept as its entry point,
/// and re-exports it whole — on top of what it always exposed
/// ([FirebaseEmulator], [FirebaseEmulatorOptions], [FirebaseEmulatorService]),
/// that also brings the emulator status types in.
library;

export 'package:tekartik_firebase_tools_common/firebase_emulator.dart';
