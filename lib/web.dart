import 'dart:convert';

// import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

enum WebDataTypes { pitScout, matchScout, currentEvents }

CachedSourceOfTruth<WebDataTypes, Map<String, dynamic>> cacheSoT =
    CachedSourceOfTruth();
final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher: Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((i) async {
    switch (i) {
      case WebDataTypes.pitScout:
        return json.decode('''{
          "How Robot?": "text",
          "AFL": "text",
          "Ohno": "notText"
        }''');
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
          },
          "driver": {
            "rating": "slider",
            "fouls": "counter"
          }
        }''');
      case WebDataTypes.currentEvents:
        return json.decode('''{
          "casf": "San Francisco Regional",
          "casv": "Silicon Valley Regional",
          "pppp": "Peepee peepee"
        }''');
    }
  }),
  sourceOfTruth: cacheSoT,
);
