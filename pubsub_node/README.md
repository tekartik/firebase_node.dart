# tekartik_pubsub_node

Scaffold for a Google Cloud Pub/Sub client on Node.js (Dart compiled with
dart2js): it pins the `@google-cloud/pubsub` npm module (`package.json`) and
loads it in its tests. The public library declares nothing yet: bindings are
to be added in `lib/src/pubsub_interop.dart` (see the package skill).

## Running the tests

```bash
npm install
dart test -p node
```
