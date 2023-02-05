import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'matchscout.dart';
import 'widgets/errorcontainer.dart';

enum PitScoutQuestionTypes { text }

Future<ListView> getQuestions(GlobalKey<FormState> k) async {
  List<FormField> items = (await stock.get(WebDataTypes.pitScout))
      .entries
      .where((e) => PitScoutQuestionTypes.values.any((t) => t.name == e.value))
      .map((e) {
    switch (PitScoutQuestionTypes.values.byName(e.value)) {
      case PitScoutQuestionTypes.text:
        return TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
              labelText: e.key, border: const OutlineInputBorder()),
          onSaved: (String? content) {
            print(content);
          },
        );
    }
  }).toList();
  return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(top: 7),
          child: index < items.length
              ? items[index]
              : ElevatedButton(
                  onPressed: () {
                    k.currentState!.save();
                    k.currentState!.reset();
                    ScaffoldMessenger.of(k.currentContext!)
                        .showSnackBar(const SnackBar(
                      content: Text("Response Sent!"),
                      behavior: SnackBarBehavior.floating,
                      closeIconColor: Colors.white70,
                      showCloseIcon: true,
                    ));
                  },
                  child: const Text("Submit"))));
}

class PitScout extends StatefulWidget {
  const PitScout({super.key});

  @override
  State<StatefulWidget> createState() => PitScoutState();
}

class PitScoutState extends State<PitScout> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MatchScout()));
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
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: FutureBuilder(
                  future: getQuestions(formKey),
                  builder: (context, snapshot) =>
                      snapshot.data ??
                      ErrorContainer(snapshot.error.toString())))));
}
