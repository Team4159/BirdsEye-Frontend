import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';
import 'matchscout.dart';

enum PitScoutQuestionTypes {
  text
}

Future<List<FormField?>> getPitScoutQuestions() async {
  // await http.get(Uri.parse("https://api.lol.xd/pitscout"))).body
  return jsonDecode('''{
    "How Robot?": "text",
    "Literally Trolled": "text",
    "Break": "lmao"
  }''', reviver: (k, v) {
    if (k is String && v is String && PitScoutQuestionTypes.values.any((t) => t.name == v)) {
      switch (PitScoutQuestionTypes.values.byName(v)) {
        case PitScoutQuestionTypes.text:
          return TextFormField(decoration: InputDecoration(labelText: k, border: const OutlineInputBorder()));
      }
    }
    return null;
  });
}

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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MatchScout()));
              },
            ),
            ListTile(
              title: const Text("Pit Scouting"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PitScout()));
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info_outline_rounded),
              applicationVersion: version,
            )
          ],
        )),
        body: Container(padding: const EdgeInsets.all(20), child: Form(autovalidateMode: AutovalidateMode.onUserInteraction, child: FutureBuilder(initialData: const <FormField>[], future: getPitScoutQuestions(), builder: (context, snapshot) => ListView.builder(itemCount: snapshot.data?.length ?? 0, itemBuilder: (context, index) => snapshot.data?[index] ?? Container(color: Colors.red))))));
  }
}
