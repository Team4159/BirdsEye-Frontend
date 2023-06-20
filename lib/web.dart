import 'dart:convert' show json;

import 'package:birdseye/main.dart';
import 'package:birdseye/matchscout.dart';
import 'package:birdseye/settings.dart';
import "package:http/http.dart" show Client;
import 'package:stock/stock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final client = Client(); // TODO remove fully

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

Future<List<int>> pitScoutGetUnfilled() => client
        .get(parseURI(
            "api/bluealliance/${SettingsState.season}/${prefs.getString('event')}/*",
            params: {"onlyUnfilled": "true"}))
        .then((resp) => List<int>.from(json.decode(resp.body), growable: false))
        .then((data) {
      data.sort();
      return data;
    });

class SupabaseInterface {
  static Future<bool> get canConnect => Supabase.instance.client
      .rpc("getavailableseasons")
      .then((_) => true)
      .catchError((_) => false);

  static final Stock<int, MatchSchema> _matchSchemaStock =
      Stock<int, MatchSchema>(
          fetcher: Fetcher.ofFuture((key) => Supabase.instance.client.rpc(
                  'gettableschema',
                  params: {"tablename": "${key}_match"}).then((resp) {
                Map<String, String> raw = Map.castFrom(resp);
                raw.removeWhere((key, value) =>
                    {"event", "match", "team", "scouter"}.contains(key));
                MatchSchema matchSchema = {};
                for (MapEntry<String, String> s in raw.entries) {
                  List<String> components = s.key.split(RegExp('[A-Z]'));
                  if (matchSchema[components.first] == null) {
                    matchSchema[components.first] = {};
                  }
                  matchSchema[components.first]![components.sublist(1).join()] =
                      MatchScoutQuestionTypes.fromSQLType(s.value);
                }
                return matchSchema;
              })),
          sourceOfTruth: CachedSourceOfTruth());
  static Future<MatchSchema> get matchSchema async => await canConnect
      ? _matchSchemaStock.fresh(SettingsState.season)
      : _matchSchemaStock.get(SettingsState.season);
}
