# workflow_ci_firestore_test

Run the firestore_node env test only (used by the `run_ci_firestore_test` github workflow).

It sets `TEKARTIK_GITHUB_ACTIONS_ENV_TEST` so that `test/firestore_node_test.dart`
is run here, while it is skipped in the regular `run_ci` workflow.

```
dart run tool/run_ci.dart
```
