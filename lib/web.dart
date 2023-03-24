import 'dart:convert' show json, jsonDecode;

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

Future<bool> getStatus(String ip) {
  return client
      .get(parseURI("", ip: ip))
      .then((resp) => resp.body == "BirdsEye Scouting Server Online!")
      .onError((_, __) => false);
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

Future<Response> postResponse(
    WebDataTypes dataType, Map<String, dynamic> body) {
  switch (dataType) {
    case WebDataTypes.pitScout:
      return client.post(
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

class TeamAssignmentResponse {
  String teamNumber;

  TeamAssignmentResponse(this.teamNumber);

  factory TeamAssignmentResponse.fromJson(dynamic json) {
    return TeamAssignmentResponse(json["team_number"] as String);
  }
}

Future<TeamAssignmentResponse> getScoutingAssignment(String matchId) {
  return client.post(
      parseURI(
          "/${SettingsState.season}/events/${prefs.getString('event')}/matches/$matchId/scout"),
      body: {}).then((value) {
    print(value.body);
    return TeamAssignmentResponse.fromJson(jsonDecode(value.body));
  });
}

Future<List<int>> pitScoutGetUnfilled() => client
    .get(parseURI(
        "api/bluealliance/${SettingsState.season}/${prefs.getString('event')}/*",
        params: {"onlyUnfilled": "true"}))
    .then((resp) => List<int>.from(json.decode(resp.body), growable: false));

Future<List<String>> getTableList(int season) => client
    .get(parseURI("api/$season/tables"))
    .then((resp) => List<String>.from(json.decode(resp.body), growable: false));

Future<Response> createTables(int season, String eventCode) =>
    client.put(parseURI("api/$season/tables"), body: eventCode);
