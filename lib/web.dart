import 'dart:convert';

import 'package:http/http.dart' as http;
// TODO: Implement Caching System

Future<num> currentSeason() async {
  var resp =
      await http.get(Uri.parse("https://frc-api.firstinspires.org/v3.0/"));
  return jsonDecode(resp.body).currentSeason;
}

Future<List<Map<String, String>>> getPitScoutQuestions() async {
  // return jsonDecode(
  //     (await http.get(Uri.parse("https://api.lol.xd/pitscout"))).body);
  return [
    {"How Robot?": "text"},
    {"Literally Trolled": "text"}
  ];
}
