/// Hard-coded minimum npm constraints of the firebase node packages.
///
/// Pure constants, no io dependency.
library;

/// `firebase-admin` npm package name.
const firebaseAdminNpmPackageName = 'firebase-admin';

/// `firebase-functions` npm package name.
const firebaseFunctionsNpmPackageName = 'firebase-functions';

/// `@google-cloud/firestore` npm package name.
const googleCloudFirestoreNpmPackageName = '@google-cloud/firestore';

/// Minimum `firebase-admin` version range (as in `package.json`).
const firebaseAdminNpmMinConstraint = '^14.4.0';

/// Minimum `firebase-functions` version range (as in `package.json`).
const firebaseFunctionsNpmMinConstraint = '^7.3.2';

/// Minimum `@google-cloud/firestore` version range (as in `package.json`).
const googleCloudFirestoreNpmMinConstraint = '^9.1.0';

/// Minimum version ranges of the npm dependencies used by the firebase node
/// packages (name -> range).
///
/// Only the lower bound of each range is enforced: a `package.json` declaring
/// `firebase-admin: ^14.4.0` or `>=14.5.0` is fine, `^14.2.0` is not.
const firebaseNodeNpmMinConstraints = <String, String>{
  firebaseAdminNpmPackageName: firebaseAdminNpmMinConstraint,
  firebaseFunctionsNpmPackageName: firebaseFunctionsNpmMinConstraint,
  googleCloudFirestoreNpmPackageName: googleCloudFirestoreNpmMinConstraint,
};
