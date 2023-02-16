import 'dart:convert';

import 'package:birdseye/main.dart';
import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

import 'settings.dart';

enum WebDataTypes { pitScout, matchScout, currentEvents }

CachedSourceOfTruth<WebDataTypes, Map<String, dynamic>> cacheSoT =
    CachedSourceOfTruth();
final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher:
      Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((dataType) async {
    switch (dataType) {
      case WebDataTypes.pitScout:
        return json.decode((await http.get(
                Uri.http(serverIP, "/api/${SettingsState.season}/pitschema/")))
            .body);
      case WebDataTypes.matchScout:
        return json.decode((await http.get(Uri.http(
                serverIP, "/api/${SettingsState.season}/matchschema/")))
            .body);
      case WebDataTypes.currentEvents:
        return json.decode((await http.get(Uri.http(
                serverIP,
                "/api/bluealliance/${SettingsState.season}/",
                {"ignoreDate": "true"})))
            .body);
    }
  }),
  sourceOfTruth: cacheSoT,
);

Future<bool> getStatus(String ip) {
  return http
      .get(Uri.http(ip))
      .then((value) => value.body == "BirdsEye Scouting Server Online!")
      .onError((error, stackTrace) => false);
}

// TODO: Cache the below
Future<List<dynamic>> getMatches() {
  return http
      .get(Uri.http(serverIP,
          "/api/bluealliance/${SettingsState.season}/${prefs.getString('event')}/"))
      .then((resp) => json.decode(resp.body));
}

Future<List<dynamic>> getTeams(String matchCode) {
  return http
      .get(Uri.http(serverIP,
          "/api/bluealliance/${SettingsState.season}/${prefs.getString("event")}/$matchCode/"))
      .then((resp) => json.decode(resp.body));
}

Future<http.Response> postResponse(
    WebDataTypes dataType, Map<String, dynamic> body) {
  switch (dataType) {
    case WebDataTypes.pitScout:
      return http.post(
          Uri.http(serverIP,
              "/api/${SettingsState.season}/${prefs.getString('event')}/pit/"),
          body: json.encode(body));
    case WebDataTypes.matchScout:
      return http.post(
          Uri.http(serverIP,
              "/api/${SettingsState.season}/${prefs.getString('event')}/match/"),
          body: json.encode(body));
    default:
      return Future.error(
          Exception("Unsupported Post-Response WebDataType $dataType"));
  }
}
