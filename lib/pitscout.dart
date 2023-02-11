import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';

import 'widgets/errorcontainer.dart';

enum PitScoutQuestionTypes { text }

class PitScout extends StatefulWidget {
  const PitScout({super.key});

  @override
  State<StatefulWidget> createState() => PitScoutState();
}

class PitScoutState extends State<PitScout> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, String> fields = {};
  bool _loading = false;

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
                  future: () async {
                    Iterable<Widget> items =
                        (await stock.get(WebDataTypes.pitScout))
                            .entries
                            .where((e) => PitScoutQuestionTypes.values
                                .any((t) => t.name == e.value))
                            .map((e) {
                      switch (PitScoutQuestionTypes.values.byName(e.value)) {
                        case PitScoutQuestionTypes.text:
                          return TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(labelText: e.key),
                            onSaved: (String? content) {
                              fields[e.key] = content ?? "";
                            },
                          );
                      }
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
                                    m.showSnackBar(const SnackBar(
                                        duration: Duration(minutes: 5),
                                        behavior: SnackBarBehavior.fixed,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        content: LinearProgressIndicator(
                                          backgroundColor: Colors.transparent,
                                        )));
                                    setState(() {
                                      _loading = true;
                                    });
                                    postResponse(WebDataTypes.pitScout, fields)
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 6),
                                child: e))
                            .toList());
                  }(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? snapshot.data!
                      : snapshot.hasError
                          ? ErrorContainer(snapshot.error.toString())
                          : const Center(
                              child: CircularProgressIndicator())))));
}
