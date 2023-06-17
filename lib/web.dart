import 'dart:convert' show json;

import 'package:birdseye/main.dart';
import 'package:birdseye/matchscout.dart';
import 'package:birdseye/settings.dart';
import "package:http/http.dart" show Client;
import 'package:stock/stock.dart';

final client = Client();

Uri parseURI(String path, {Map<String, dynamic>? params}) =>
    Uri.http("127.0.0.1", path, params);

final tbaRegex = RegExp(
    r"^(?<season>\d{4})(?:(?<event>[a-z0-9]{2,})(?:_(?<match>(?:qm\d+?)|(?:(?:qf|sf|f)\dm\d)|\*))?)?$");
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
      return client
          .get(parseURI(
              "/api/bluealliance/${groups.sublist(0, i >= 0 ? i : null).join("/")}",
              params: {"ignoreDate": "true"}))
          .then((resp) => Map<String, String>.from(json.decode(resp.body)));
    }),
    sourceOfTruth: tbaSoT);

enum WebDataTypes { pitScout, matchScout }

final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher: Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((dataType) {
    switch (dataType) {
      case WebDataTypes.pitScout:
        return client
            .get(parseURI("/api/${SettingsState.season}/pitschema"))
            .then((resp) => json.decode(resp.body));
      case WebDataTypes.matchScout:
        return client
            .get(parseURI("/api/${SettingsState.season}/matchschema"))
            .then((resp) => Map.castFrom(json.decode(resp.body)))
            .then((data) => data.map((k, v) => MapEntry<String, dynamic>(
                k,
                Map.fromEntries(v.entries.where((e) => MatchScoutQuestionTypes
                    .values
                    .any((element) => e.value == element.name))))));
    }
  }),
  sourceOfTruth: CachedSourceOfTruth(),
);

Future<List<int>> pitScoutGetUnfilled() => client
        .get(parseURI(
            "api/bluealliance/${SettingsState.season}/${prefs.getString('event')}/*",
            params: {"onlyUnfilled": "true"}))
        .then((resp) => List<int>.from(json.decode(resp.body), growable: false))
        .then((data) {
      data.sort();
      return data;
    });
