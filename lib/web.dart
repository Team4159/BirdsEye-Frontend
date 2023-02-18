import 'dart:convert';

import 'package:birdseye/main.dart';
import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

import 'settings.dart';

enum WebDataTypes { pitScout, matchScout }

CachedSourceOfTruth<WebDataTypes, Map<String, dynamic>> cacheSoT =
    CachedSourceOfTruth();
final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher: Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((dataType) {
    switch (dataType) {
      case WebDataTypes.pitScout:
        return http
            .get(Uri.https(serverIP, "/api/${SettingsState.season}/pitschema/"))
            .then((resp) => json.decode(resp.body));
      case WebDataTypes.matchScout:
        return http
            .get(Uri.https(
                serverIP, "/api/${SettingsState.season}/matchschema/"))
            .then((resp) => json.decode(resp.body));
    }
  }),
  sourceOfTruth: cacheSoT,
);

Future<bool> getStatus(String ip) {
  return http
      .get(Uri.https(ip))
      .then((value) => value.body == "BirdsEye Scouting Server Online!")
      .onError((error, stackTrace) => false);
}

final tbaRegex = RegExp(
    r"(?<season>\d{4})(?:(?<event>[a-z]{4})(?:_(?<match>(?:qm\d+?)|(?:(?:qf|sf|f)\dm\d))?)?)?");
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
        Uri.https(
            serverIP,
            "/api/bluealliance/${groups.sublist(0, i >= 0 ? i : null).join("/")}",
            {"ignoreDate": "true"}),
      )
          .then((resp) {
        return Map.from(json.decode(resp.body));
      });
    }),
    sourceOfTruth: CachedSourceOfTruth());

Future<http.Response> postResponse(
    WebDataTypes dataType, Map<String, dynamic> body) {
  switch (dataType) {
    case WebDataTypes.pitScout:
      return http.post(
          Uri.https(serverIP,
              "/api/${SettingsState.season}/${prefs.getString('event')}/pit/"),
          body: json.encode(body));
    case WebDataTypes.matchScout:
      return http.post(
          Uri.https(serverIP,
              "/api/${SettingsState.season}/${prefs.getString('event')}/match/"),
          body: json.encode(body));
  }
}
