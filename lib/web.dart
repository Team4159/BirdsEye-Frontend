import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock/stock.dart';

enum WebDataTypes { pit }

final stock = Stock<WebDataTypes, Map<String, dynamic>>(
  fetcher: Fetcher.ofFuture<WebDataTypes, Map<String, dynamic>>((i) async {
    switch (i) {
      case WebDataTypes.pit:
        return json.decode(
            (await http.get(Uri.parse("https://api.lol.xd/pitscout"))).body);
    }
  }),
  sourceOfTruth: CachedSourceOfTruth(),
);

// TODO: send back to server

Future<num> currentSeason() async {
  var resp =
      await http.get(Uri.parse("https://frc-api.firstinspires.org/v3.0/"));
  return jsonDecode(resp.body).currentSeason;
}
