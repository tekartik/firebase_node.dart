@TestOn('node')
library;

import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:tekartik_firebase_functions/firebase_functions.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_https_node.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_node.dart';
import 'package:tekartik_firebase_functions_node/src/node/firebase_functions_scheduler_node.dart';
import 'package:test/test.dart';

/// The deployment manifest of a native function.
js.JSObject _endpointOf(FirebaseFunction function) =>
    (function as FirebaseFunctionNode).nativeInstance.getProperty<js.JSObject>(
      '__endpoint'.toJS,
    );

/// The property names of a native object.
Iterable<Object?> _keys(js.JSObject object) =>
    (object.dartify() as Map).keys.toList();

/// Calls the native [function] with a CORS preflight request from a browser,
/// returning the status code and the headers set.
Future<(int, Map<String, String>)> _preflight(FirebaseFunction function) {
  var headers = <String, String>{};
  var done = Completer<(int, Map<String, String>)>();
  var res = js.JSObject();
  void finish() {
    if (!done.isCompleted) {
      done.complete(((res['statusCode'] as js.JSNumber).toDartInt, headers));
    }
  }

  res['statusCode'] = 200.toJS;
  res['setHeader'] = ((js.JSString name, js.JSAny value) {
    headers[name.toDart.toLowerCase()] = value.dartify().toString();
  }).toJS;
  res['getHeader'] =
      ((js.JSString name) => headers[name.toDart.toLowerCase()]?.toJS).toJS;
  res['on'] = ((js.JSString event, js.JSFunction callback) {}).toJS;
  res['status'] = ((js.JSNumber code) {
    res['statusCode'] = code;
    return res;
  }).toJS;
  res['send'] = (([js.JSAny? body]) => finish()).toJS;
  res['json'] = (([js.JSAny? body]) => finish()).toJS;
  res['end'] = (([js.JSAny? body]) => finish()).toJS;

  var req = js.JSObject();
  req['method'] = 'OPTIONS'.toJS;
  req['url'] = '/'.toJS;
  var requestHeaders = js.JSObject();
  requestHeaders['origin'] = 'https://app.example'.toJS;
  requestHeaders['access-control-request-method'] = 'POST'.toJS;
  req['headers'] = requestHeaders;
  req['header'] = ((js.JSString name) => null).toJS;
  req['get'] = ((js.JSString name) => null).toJS;

  (function as FirebaseFunctionNode).nativeInstance.callAsFunction(
    null,
    req,
    res,
  );
  return done.future.timeout(const Duration(seconds: 10));
}

void main() {
  var functions = firebaseFunctionsNode;
  group('native options', () {
    test('only the values set', () {
      expect(_keys(toNodeHttpsOptions(HttpsOptions())), isEmpty);
      expect(_keys(toNodeCallableOptions(HttpsCallableOptions())), isEmpty);
      expect(
        _keys(
          toNodeScheduleOptions(ScheduleOptions(schedule: 'every 1 hours')),
        ),
        ['schedule'],
      );
      var callableOptions = toNodeCallableOptions(
        HttpsCallableOptions(
          region: regionBelgium,
          cors: true,
          enforceAppCheck: false,
          consumeAppCheckToken: true,
          memory: runtimeOptionsMemory2GB,
        ),
      ).dartify();
      expect(callableOptions, {
        'region': regionBelgium,
        'cors': true,
        'enforceAppCheck': false,
        'consumeAppCheckToken': true,
        'memory': runtimeOptionsMemory2GB,
      });
      expect(
        toNodeScheduleOptions(
          ScheduleOptions(
            schedule: 'every 1 hours',
            timeZone: 'Europe/Paris',
            region: regionBelgium,
            timeoutSeconds: 60,
          ),
        ).dartify(),
        {
          'schedule': 'every 1 hours',
          'timeZone': 'Europe/Paris',
          'region': regionBelgium,
          'timeoutSeconds': 60,
        },
      );
    });

    test('a schedule without timeoutSeconds', () {
      // firebase-functions 7.3+ refused a null timeoutSeconds.
      var function = functions.scheduler.onSchedule(
        ScheduleOptions(schedule: 'every 5 minutes'),
        (event) async {},
      );
      expect(
        _endpointOf(function).hasProperty('scheduleTrigger'.toJS).toDart,
        isTrue,
      );
    });

    test('a callable with options keeps its default CORS', () async {
      var (status, headers) = await _preflight(
        functions.https.onCall(
          (request) async => 'ok',
          callableOptions: HttpsCallableOptions(
            memory: runtimeOptionsMemory2GB,
          ),
        ),
      );
      expect(status, 204);
      expect(headers['access-control-allow-origin'], 'https://app.example');
      // And none when disabled.
      (status, headers) = await _preflight(
        functions.https.onCall(
          (request) async => 'ok',
          callableOptions: HttpsCallableOptions(cors: false),
        ),
      );
      expect(headers['access-control-allow-origin'], isNull);
    });

    test('function options without region keep the global region', () {
      functions.globalOptions = GlobalOptions(region: regionBelgium);
      Object? regionOf(FirebaseFunction function) =>
          _endpointOf(function).getProperty<js.JSAny?>('region'.toJS).dartify();
      expect(
        regionOf(
          functions.https.onRequest(
            (request) => request.response.send('ok'),
            httpsOptions: HttpsOptions(memory: runtimeOptionsMemory2GB),
          ),
        ),
        [regionBelgium],
      );
      expect(
        regionOf(
          functions.https.onCall(
            (request) async => 'ok',
            callableOptions: HttpsCallableOptions(cors: true),
          ),
        ),
        [regionBelgium],
      );
      expect(
        regionOf(
          functions.scheduler.onSchedule(
            ScheduleOptions(schedule: 'every 5 minutes', timeoutSeconds: 60),
            (event) async {},
          ),
        ),
        [regionBelgium],
      );
      expect(
        regionOf(
          functions.https.onRequest(
            (request) => request.response.send('ok'),
            httpsOptions: HttpsOptions(region: regionFrankfurt),
          ),
        ),
        [regionFrankfurt],
      );
    });
  });
}
