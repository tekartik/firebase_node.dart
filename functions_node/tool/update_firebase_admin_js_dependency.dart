import 'package:process_run/shell.dart';

// https://firebase.google.com/docs/functions/get-started
Future<void> main() async {
  var shell = Shell().cd('deploy/functions');
  await shell.run('''
npm install firebase-functions@latest firebase-admin@latest --save
npm install -g firebase-tools
  ''');
}
