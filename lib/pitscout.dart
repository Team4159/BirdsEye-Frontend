// fetch pit scouting questions -> cache on device -> text field entries -> send back to server
import 'package:flutter/material.dart';

import 'main.dart';
import 'matchscout.dart';
import 'web.dart';

class PitScout extends StatelessWidget {
  const PitScout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // TODO: Nested Navigation https://docs.flutter.dev/cookbook/effects/nested-nav
        appBar: AppBar(
          title: const Text("Pit Scouting"),
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
            padding: const EdgeInsets.all(20),
            child: FutureBuilder(
                initialData: const <Map<String, String>>[],
                future: getPitScoutQuestions(),
                builder: (context, snapshot) => Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          var li = snapshot.data?[index];
                          if (li == null) return Container(color: Colors.red);
                          return TextFormField(
                              decoration: InputDecoration(
                                  labelText: li.keys.first,
                                  border: const OutlineInputBorder()));
                        })))));
  }
}
