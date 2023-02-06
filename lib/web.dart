import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

enum WebDataTypes { pitScout, matchScout }

CachedSourceOfTruth<WebDataTypes, Map<String, dynamic>> cacheSoT =
    CachedSourceOfTruth();
final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher: Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((i) async {
    switch (i) {
      case WebDataTypes.pitScout:
        return json.decode('''{
          "How Robot?": "text",
          "Ohno": "notText"
        }'''); // (await http.get(Uri.parse("https://api.lol.xd/pitscout"))).body
      case WebDataTypes.matchScout:
        return json.decode('''{
          "auto": {
            "coneAttempted": "counter",
            "coneLow": "counter",
            "coneMid": "counter",
            "coneHig": "counter",
            "mobility":"toggle"
          },
          "teleop": {
            "coneAttempted": "counter",
            "coneLow": "counter",
            "coneMid": "counter",
            "coneHig": "counter"
          },
          "endgame": {
            "docked": "toggle",
            "engaged":"toggle"
          }
        }'''); /*
          "driver": {
            "rating": "slider",
            "fouls": "counter"
          }*/
    }
  }),
  sourceOfTruth: cacheSoT,
);

// TODO: send back to server

Future<num> currentSeason() async {
  http.Response resp =
      await http.get(Uri.parse("https://frc-api.firstinspires.org/v3.0/"));
  return jsonDecode(resp.body).currentSeason;
}
