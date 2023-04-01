import 'dart:convert' show json;

import 'package:birdseye/main.dart';
import 'package:birdseye/matchscout.dart';
import 'package:birdseye/settings.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:stock/stock.dart';

final client = Client();

final hasLetter = RegExp(r"[a-z]", caseSensitive: false);
Uri parseURI(String path, {String? ip, Map<String, dynamic>? params}) {
  ip ??= prefs.getString("ip")!;
  return hasLetter.hasMatch(ip)
      ? Uri.https(ip, path, params)
      : Uri.http(ip, path, params);
}

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

Future<Response> postResponse(WebDataTypes dataType, Map<String, dynamic> body,
    {bool patch = false}) {
  switch (dataType) {
    case WebDataTypes.pitScout:
      return patch
          ? client.patch(
              parseURI(
                  "/api/${SettingsState.season}/${prefs.getString('event')}/pit"),
              body: json.encode(body))
          : client.post(
              parseURI(
                  "/api/${SettingsState.season}/${prefs.getString('event')}/pit"),
              body: json.encode(body));
    case WebDataTypes.matchScout:
      return client.post(
          parseURI(
              "/api/${SettingsState.season}/${prefs.getString('event')}/match"),
          body: json.encode(body));
  }
}

Future<bool> getStatus(String ip) => client
    .get(parseURI("", ip: ip))
    .then((resp) => resp.body == "BirdsEye Scouting Server Online!")
    .onError((_, __) => false);

Future<List<int>> pitScoutGetUnfilled() => client
        .get(parseURI(
            "api/bluealliance/${SettingsState.season}/${prefs.getString('event')}/*",
            params: {"onlyUnfilled": "true"}))
        .then((resp) => List<int>.from(json.decode(resp.body), growable: false))
        .then((data) {
      data.sort();
      return data;
    });

Future<Map<String, String>> pitScoutGetMyResponse(int teamNumber) => client
        .get(parseURI(
            "api/${SettingsState.season}/${prefs.getString('event')}/pit",
            params: {
              "name": prefs.getString('name'),
              "teamNumber": teamNumber.toString()
            }))
        .then((resp) => Map<String, dynamic>.from(json.decode(resp.body)[0]))
        .then((data) {
      data.removeWhere((k, v) =>
          {"teamNumber", "name"}.contains(k) || v is! String || v.isEmpty);
      return data.cast<String, String>();
    }).catchError((e) => <String, String>{});

Future<List<String>> getTableList(int season) => client
    .get(parseURI("api/$season/tables"))
    .then((resp) => List<String>.from(json.decode(resp.body), growable: false));

Future<Response> createTables(int season, String eventCode) =>
    client.put(parseURI("api/$season/tables"), body: eventCode);
