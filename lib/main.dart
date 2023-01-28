import 'package:flutter/material.dart';

void main() => runApp(const BirdsEye());

class BirdsEye extends StatelessWidget {
  const BirdsEye({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Bird's Eye",
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            body: GridView.count(
          crossAxisCount: 2,
          children: [
            ListTile(title: Text("Match Scouting")),
            ListTile(title: Text("Pit Scouting")),
            ListTile(title: Text("Analysis & Ranking"))
          ],
        )));
  }
}
