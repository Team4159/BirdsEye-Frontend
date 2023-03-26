import 'dart:convert' show json, jsonDecode;
import 'dart:ffi';

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
  int teamNumber;

  TeamAssignmentResponse(this.teamNumber);

  factory TeamAssignmentResponse.fromJson(dynamic json) {
    return TeamAssignmentResponse(json["team_number"] as int);
  }
}

Future<TeamAssignmentResponse> getScoutingAssignment(String matchId) {
  var uri = parseURI(
      "/${SettingsState.season}/events/${prefs.getString('event')}/matches/$matchId/scout");
  print('uri: $uri');
  return client.post(uri, body: {}).then((value) {
    print(value.body);
    return TeamAssignmentResponse.fromJson(jsonDecode(value.body));
  });
}

Future<List<CurrentMatchesResponse>> getCurrentMatches() {
  var uri = parseURI(
      "/${SettingsState.season}/events/${prefs.getString('event')}/current_matches");
  print('uri: $uri');
  return client.get(uri).then((value) {
    print(value.body);
    var list = jsonDecode(value.body) as List;
    return list.map((e) => CurrentMatchesResponse.fromJson(e)).toList();
  });
}

Future<Response> freeScoutingAssignment(String matchId, int teamNumber) {
  var uri = parseURI(
      "/${SettingsState.season}/events/${prefs.getString('event')}/matches/$matchId/stop_scouting/$teamNumber");
  print('uri: $uri');
  return client.post(uri, body: {}).then((value) {
    print(value.body);
    return value;
  });
}

enum TeamColor {
  blue,
  red;

  static TeamColor fromString(String str) {
    if (str == 'blue') {
      return TeamColor.blue;
    } else if (str == 'red') {
      return TeamColor.red;
    }

    throw 'invalid team color';
  }
}

/*

{
  number: 604,
  isAssigned: true,
  color: "red" 
}
*/

class TeamAssignment {
  int teamNumber;
  bool isAssigned;
  TeamColor color;

  TeamAssignment(this.teamNumber, this.isAssigned, this.color);

  factory TeamAssignment.fromJson(dynamic json) {
    return TeamAssignment(json['number'] as int, json['isAssigned'] as bool,
        TeamColor.fromString(json['color'] as String));
  }
}

class CurrentMatchesResponse {
  String key;
  List<TeamAssignment> teams;

  CurrentMatchesResponse(this.key, this.teams);

  factory CurrentMatchesResponse.fromJson(dynamic json) {
    var list = json['teams'] as List;
    var teamsList = list.map((e) => TeamAssignment.fromJson(e)).toList();
    return CurrentMatchesResponse(json['key'], teamsList);
  }
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
