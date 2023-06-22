import 'dart:convert' show json;

import 'package:birdseye/main.dart';
import 'package:birdseye/matchscout.dart';
import 'package:birdseye/settings.dart';
import "package:http/http.dart" show Client;
import 'package:stock/stock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final client = Client();

Future getJson(String path) => !prefs.containsKey("tbaKey")
    ? Future.error("No TBA API Key!")
    : client
        .get(Uri.https("www.thebluealliance.com", "/api/v3/$path",
            {"X-TBA-Auth-Key": prefs.getString("tbaKey")}))
        .then((resp) => resp.statusCode < 400
            ? json.decode(resp.body)
            : throw Exception(resp.body));

final tbaRegex = RegExp(
    r"^(?<season>\d{4})(?:(?<event>[a-z0-9]{2,})(?:_(?<match>(?:qm\d+?)|(?:(?:qf|sf|f)\dm\d)|\*))?)?$");
final tbaStock = Stock<String, Map<String, String>>(
    fetcher: Fetcher.ofFuture<String, Map<String, String>>((String key) async {
      RegExpMatch? rm = tbaRegex.firstMatch(key);
      String? season = rm?.namedGroup("season");
      String? event = rm?.namedGroup("event");
      String? match = rm?.namedGroup("match");
      if (season == null) {
        // index
        var data = Map<String, dynamic>.from(await getJson("status"));
        return (data
              ..removeWhere(
                  (key, _) => !{"max_season", "current_season"}.contains(key)))
            .cast<String, String>();
      } else if (event == null) {
        // season
        var data = List<Map<String, dynamic>>.from(
            await getJson("events/$season/simple"));
        return Map.fromEntries(
            data.map((event) => MapEntry(event['event_code'], event['name'])));
      } else if (match == null) {
        // event
        var data = List<String>.from(
            await getJson("event/$season$event/matches/keys"));
        return Map.fromEntries(data.map(
            (matchCode) => MapEntry(matchCode.split("_").last, matchCode)));
      } else if (match == "*") {
        // match*
        var data =
            List<String>.from(await getJson("event/$season$event/teams/keys"));
        return Map.fromEntries(
            data.map((teamCode) => MapEntry(teamCode.substring(3), "*")));
      } else {
        // match
        var data = Map<String, dynamic>.from(
            await getJson("match/$season${event}_$match/simple"));
        Map<String, String> o = {};
        for (MapEntry<String, dynamic> alliance
            in Map<String, dynamic>.from(data['alliances']).entries) {
          for (MapEntry<int, String> team
              in List<String>.from(alliance.value['team_keys'])
                  .asMap()
                  .entries) {
            if (team.value.substring(3) != "0") {
              o[team.value.substring(3)] = "${alliance.key}${team.key + 1}";
            }
          }
        }
        return o;
      }
    }),
    sourceOfTruth: CachedSourceOfTruth());

Future<List<int>> pitScoutGetUnfilled() => tbaStock
        .get("${SettingsState.season}${prefs.getString('event')}_*")
        .then((data) => Set<int>.of(data.keys.map(int.parse)))
        .then((teams) async {
      Set<int> filledteams = await Supabase.instance.client
          .from("${SettingsState.season}_pit")
          .select<List<Map<String, dynamic>>>("team")
          .eq("event", prefs.getString('event'))
          .then((value) => value.map((e) => int.parse(e['team'])).toSet());
      return teams.difference(filledteams).toList()..sort();
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
                  List<String> components = s.key.split('_');
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
