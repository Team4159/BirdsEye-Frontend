import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';

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
          decoration: InputDecoration(labelText: e.key),
          onSaved: (String? content) {
            print(content);
          },
        );
    }
  }).toList();
  return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: index < items.length
              ? items[index]
              : ElevatedButton(
                  onPressed: () {
                    k.currentState!.save();
                    k.currentState!.reset();
                    ScaffoldMessenger.of(k.currentContext!).showSnackBar(
                        const SnackBar(content: Text("Response Sent!")));
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
      appBar: AppBar(
        title: const Text("Pit Scouting"),
      ),
      drawer: getDrawer(context),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: FutureBuilder(
                  future: getQuestions(formKey),
                  builder: (context, snapshot) => snapshot.hasData
                      ? snapshot.data!
                      : snapshot.hasError
                          ? ErrorContainer(snapshot.error.toString())
                          : const Center(
                              child: CircularProgressIndicator())))));
}
