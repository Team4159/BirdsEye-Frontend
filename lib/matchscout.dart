import 'package:birdseye/widgets/counterformfield.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/sliderformfield.dart';
import 'package:birdseye/widgets/toggleformfield.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'web.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScout extends StatefulWidget {
  const MatchScout({super.key});

  @override
  State<StatefulWidget> createState() => MatchScoutState();
}

class MatchScoutState extends State<MatchScout> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, Map<String, dynamic>> fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Match Scouting"),
      ),
      drawer: getDrawer(context),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: FutureBuilder(
                  future: () async {
                    Iterable<Widget> items =
                        (await stock.get(WebDataTypes.matchScout))
                            .entries
                            .map((e1) {
                      Iterable<MapEntry<String, dynamic>> a = e1.value.entries
                          .where((e) => MatchScoutQuestionTypes.values
                              .any((t) => t.name == e.value));
                      return Column(children: [
                        Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            e1.key,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                        GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 3 / 1,
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            shrinkWrap: true,
                            children: a.map((e2) {
                              switch (MatchScoutQuestionTypes.values
                                  .byName(e2.value)) {
                                case MatchScoutQuestionTypes.text:
                                  return TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    expands: true,
                                    decoration:
                                        InputDecoration(labelText: e2.key),
                                    onSaved: (String? content) {
                                      fields[e1.key] = fields[e1.key] ?? {};

                                      fields[e1.key]![e2.key] = content;
                                    },
                                  );
                                case MatchScoutQuestionTypes.counter:
                                  return CounterFormField(
                                      initialValue: 0,
                                      labelText: e2.key,
                                      onSaved: (int? content) {
                                        fields[e1.key] = fields[e1.key] ?? {};

                                        fields[e1.key]![e2.key] = content;
                                      });
                                case MatchScoutQuestionTypes.toggle:
                                  return ToggleFormField(
                                      labelText: e2.key,
                                      onSaved: (bool? content) {
                                        fields[e1.key] = fields[e1.key] ?? {};

                                        fields[e1.key]![e2.key] = content;
                                      });
                                case MatchScoutQuestionTypes.slider:
                                  return SliderFormField(
                                      labelText: e2.key,
                                      onSaved: (double? contentd) {
                                        fields[e1.key] = fields[e1.key] ?? {};

                                        int? content = contentd?.toInt();
                                        fields[e1.key]![e2.key] = content;
                                      });
                              }
                            }).toList())
                      ]);
                    });
                    return ListView(
                        children: items
                            .followedBy([
                              ElevatedButton(
                                  onPressed: () {
                                    if (_loading) return;
                                    fields.clear();
                                    formKey.currentState!.save();
                                    formKey.currentState!.reset();
                                    var m = ScaffoldMessenger.of(context);
                                    m.showSnackBar(SnackBar(
                                        duration: const Duration(minutes: 5),
                                        behavior: SnackBarBehavior.fixed,
                                        elevation: 0,
                                        content: Row(children: const [
                                          CircularProgressIndicator(),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              child: Text("Loading"))
                                        ])));
                                    setState(() {
                                      _loading = true;
                                    });
                                    postResponse(
                                            WebDataTypes.matchScout, fields)
                                        .then((response) {
                                      m.hideCurrentSnackBar();
                                      setState(() {
                                        _loading = false;
                                      });
                                      m.showSnackBar(const SnackBar(
                                          content: Text("Response Sent!")));
                                    }).catchError((e) {
                                      m.hideCurrentSnackBar();
                                      setState(() {
                                        _loading = false;
                                      });
                                      m.showSnackBar(SnackBar(
                                          content: Text(e.toString())));
                                    });
                                  },
                                  child: _loading
                                      ? const Text("Waiting..")
                                      : const Text("Submit"))
                            ])
                            .map((e) => Padding(
                                padding: const EdgeInsets.all(15), child: e))
                            .toList());
                  }(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? snapshot.data!
                      : snapshot.hasError
                          ? ErrorContainer(snapshot.error.toString())
                          : const Center(
                              child: CircularProgressIndicator())))));
}
