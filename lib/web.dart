import 'dart:convert';

import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

Uri parseURI(String path, {Map<String, dynamic>? params}) {
  return kDebugMode
      ? Uri.http("localhost:5000", path, params)
      : Uri.https(serverIP, path, params);
}

enum WebDataTypes { pitScout, matchScout }

final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher: Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((dataType) {
    late Uri uri;
    switch (dataType) {
      case WebDataTypes.pitScout:
        uri = parseURI("/api/${SettingsState.season}/pitschema/");
        break;
      case WebDataTypes.matchScout:
        uri = parseURI("/api/${SettingsState.season}/matchschema/");
        break;
    }
    return http.get(uri).then((resp) => json.decode(resp.body));
  }),
  sourceOfTruth: CachedSourceOfTruth(),
);

Future<bool> getStatus(String ip) {
  return http
      .get(Uri.https(ip))
      .then((value) => value.body == "BirdsEye Scouting Server Online!")
      .onError((error, stackTrace) => false);
}

final tbaRegex = RegExp(
    r"(?<season>\d{4})(?:(?<event>[a-z]{2,})(?:_(?<match>(?:qm\d+?)|(?:(?:qf|sf|f)\dm\d))?)?)?");
final CachedSourceOfTruth<String, Map<String, String>> tbaSoT =
    CachedSourceOfTruth();
final tbaStock = Stock<String, Map<String, String>>(
    fetcher: Fetcher.ofFuture<String, Map<String, String>>((String key) {
      var rm = tbaRegex.firstMatch(key);
      List<String?> groups = rm == null
          ? []
          : [
              rm.namedGroup("season"),
              rm.namedGroup("event"),
              rm.namedGroup("match")
            ];
      var i = groups.indexOf(null);
      return http
          .get(
        parseURI(
            "/api/bluealliance/${groups.sublist(0, i >= 0 ? i : null).join("/")}",
            params: {"ignoreDate": "true"}),
      )
          .then((resp) {
        return Map.from(json.decode(resp.body));
      });
    }),
    sourceOfTruth: tbaSoT);

Future<http.Response> postResponse(
    WebDataTypes dataType, Map<String, dynamic> body) {
  switch (dataType) {
    case WebDataTypes.pitScout:
      return http.post(
          parseURI(
              "/api/${SettingsState.season}/${prefs.getString('event')}/pit/"),
          body: json.encode(body));
    case WebDataTypes.matchScout:
      return http.post(
          parseURI(
              "/api/${SettingsState.season}/${prefs.getString('event')}/match/"),
          body: json.encode(body));
  }
}
