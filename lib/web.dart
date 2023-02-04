import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// TODO: Implement Caching System, send back to server

Future<num> currentSeason() async {
  var resp = await http.get(Uri.parse("https://frc-api.firstinspires.org/v3.0/"));
  return jsonDecode(resp.body).currentSeason;
}
