import 'dart:convert';

import 'package:birdseye/main.dart';
import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

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
        return json.decode('''{
          "casf": "San Francisco Regional",
          "casv": "Silicon Valley Regional",
          "pppp": "Peepee peepee"
        }''');
    }
  }),
  sourceOfTruth: cacheSoT,
);
