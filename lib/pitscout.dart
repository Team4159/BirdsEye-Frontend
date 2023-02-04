import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'matchscout.dart';

enum PitScoutQuestionTypes { text }

Future<ListView> getQuestions() async {
  List<FormField> items = (await stock.get(WebDataTypes.pit))
      .entries
      .where((e) => PitScoutQuestionTypes.values.any((t) => t.name == e.value))
      .map((e) {
    switch (PitScoutQuestionTypes.values.byName(e.value)) {
      case PitScoutQuestionTypes.text:
        return TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                labelText: e.key, border: const OutlineInputBorder()));
    }
  }).toList();
  return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) =>
          Padding(padding: const EdgeInsets.only(top: 7), child: items[index]));
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
            child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: FutureBuilder(
                    future: getQuestions(),
                    builder: (context, snapshot) =>
                        snapshot.data ??
                        Container(
                            color: Colors.red[800],
                            child: Center(
                                child: Text(snapshot.error.toString())))))));
  }
}
