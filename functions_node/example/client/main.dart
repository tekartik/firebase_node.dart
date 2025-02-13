// ignore_for_file: depend_on_referenced_packages

import 'package:tekartik_http/http.dart';
import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

Future main(List<String> arguments) async {
  await mainMenu(arguments, () {
    item('io http hello v2', () async {
      // This test cors on the web
      var client = Client();
      var result = await httpClientRead(
        client,
        httpMethodGet,
        Uri.parse('http://localhost:4999/thelloworldv2'),
      );
      write('result: $result');
    });
    item('io http hello v2 cors', () async {
      // This test cors on the web
      var client = Client();
      var result = await httpClientRead(
        client,
        httpMethodPost,
        Uri.parse('http://localhost:4999/thelloworldcorsv2'),
      );
      write('result: $result');
    });
    item('local firebase http hello v2', () async {
      // This test cors on the web
      var client = Client();
      var result = await httpClientRead(
        client,
        httpMethodGet,
        Uri.parse(
          'http://localhost:5000/tekartik-eu-dev/europe-west1/thelloworldv2',
        ),
      );
      write('result: $result');
    });
    item('local firebase http hello v2 cors', () async {
      // This test cors on the web
      var client = Client();
      var result = await httpClientRead(
        client,
        httpMethodPost,
        Uri.parse(
          'http://localhost:5000/tekartik-eu-dev/europe-west1/thelloworldcorsv2',
        ),
      );
      write('result: $result');
    });
  });
}
