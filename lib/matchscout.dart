// get latest match scouting form -> cache -> ensure app version matches -> process into a form -> user fills form out -> send to server w/ season year, event id, match #
import 'package:birdseye/widgets/counter.dart';
import 'package:birdseye/widgets/toggle.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'pitscout.dart';
import 'web.dart';
import 'widgets/errorcontainer.dart';

enum MatchScoutQuestionTypes {
  text,
  counter,
  toggle, /*slider*/
}

Future<ListView> getQuestions(GlobalKey<FormState> k) async {
  List<Widget> items =
      (await stock.get(WebDataTypes.matchScout)).entries.map((e1) {
    Iterable<MapEntry<String, dynamic>> a = e1.value.entries.where(
        (e) => MatchScoutQuestionTypes.values.any((t) => t.name == e.value));

    return ListBody(children: [
      Align(
        alignment: Alignment.topCenter,
        child: Text(
          e1.key,
          style: const TextStyle(
            fontFamily: "varela round",
            fontSize: 36,
            letterSpacing: 5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          children: a.map((e2) {
            switch (MatchScoutQuestionTypes.values.byName(e2.value)) {
              case MatchScoutQuestionTypes.text:
                return TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: e2.key, border: const OutlineInputBorder()),
                  onSaved: (String? content) {
                    print(content);
                  },
                );
              case MatchScoutQuestionTypes.counter:
                return CounterFormField(
                    initialValue: 0,
                    labelText: e2.key,
                    onSaved: (int? content) {
                      print(content);
                    });
              case MatchScoutQuestionTypes.toggle:
                return ToggleFormField(
                    labelText: e2.key,
                    onSaved: (bool? content) {
                      print(content);
                    });
            }
          }).toList())
    ]);
  }).toList();
  return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
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

class MatchScout extends StatefulWidget {
  const MatchScout({super.key});

  @override
  State<StatefulWidget> createState() => MatchScoutState();
}

class MatchScoutState extends State<MatchScout> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Match Scouting"),
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
