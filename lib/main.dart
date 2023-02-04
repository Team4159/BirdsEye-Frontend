import 'package:flutter/material.dart';

import 'matchscout.dart';
import 'pitscout.dart';
import 'web.dart';

void main() => runApp(const BirdsEye());
const version = "0.0.1";
num teamNumber = 4159;

class BirdsEye extends StatelessWidget {
  const BirdsEye({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "Bird's Eye", home: MainScreen());
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bird's Eye"),
        ),
        drawer: Drawer(
            child: ListView(
          children: [
            ListTile(
              title: const Text("Match Scouting"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MatchScout()));
              },
            ),
            ListTile(
              title: const Text("Pit Scouting"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PitScout()));
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info_outline_rounded),
              applicationVersion: version,
            )
          ],
        )),
        body: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.all(20),
            child: ListView(children: [
              FutureBuilder(
                initialData: -1,
                future: currentSeason(),
                builder: (context, snapshot) => Text(
                  "Current Season: ${snapshot.hasData ? snapshot.data.toString() : DateTime.now().year}",
                  style: const TextStyle(fontSize: 24, fontFamily: "Verdana"),
                ), // TODO: Add current game name
              ),
              TextFormField(
                maxLength: 4,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(), labelText: "Team Number"),
                onFieldSubmitted: (String teamStr) {
                  teamNumber = int.tryParse(teamStr) ?? 4159;
                },
                validator: (String? teamStr) => // TODO: This doesn't work
                    ((teamStr != null) && num.tryParse(teamStr) == null)
                        ? "Team Number must be numeric!"
                        : null,
              ) // TODO: Event selector
            ])));
  }
}
