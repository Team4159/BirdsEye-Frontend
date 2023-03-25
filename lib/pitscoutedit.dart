import 'package:birdseye/main.dart';
import 'package:birdseye/pitscout.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class PitScoutEdit extends StatefulWidget {
  final Map<String, dynamic> pitQuestions;
  final Map<String, dynamic> pitResponse;

  const PitScoutEdit(
      {super.key, required this.pitQuestions, required this.pitResponse});

  @override
  State<PitScoutEdit> createState() => _PitScoutEditState();
}

class _PitScoutEditState extends State<PitScoutEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
            "Editing Pit Scout Response For Team ${widget.pitResponse["teamNumber"]}"),
      ),
      drawer: AppDrawer(),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              controller: _scrollController,
              child: Column(
                children: widget.pitResponse.entries
                    .where((e) => widget.pitQuestions.containsKey(e.key))
                    .map<Widget>((e) => Material(
                          type: MaterialType.card,
                          elevation: 1,
                          child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.pitQuestions[e.key].toString(),
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                      textScaleFactor: 1.2,
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: TextEditingController(
                                          text: widget.pitResponse[e.key]
                                              .toString()),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 8),
                                          filled: true,
                                          counterText: null,
                                          border: const OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey[700]!))),
                                      onChanged: (String? content) {
                                        _fields[e.key] = content ?? "";
                                      },
                                    )
                                  ])),
                        ))
                    .followedBy([
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ButtonStyle(enableFeedback: !_loading),
                              onPressed: () {
                                if (_loading) return;
                                ScaffoldMessengerState m =
                                    ScaffoldMessenger.of(context);
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
                                updatePitScouting({
                                  "edits": {..._fields},
                                  "teamNumber":
                                      widget.pitResponse["teamNumber"],
                                  "name": widget.pitResponse["name"],
                                }).then((Response res) {
                                  if (res.statusCode >= 400) {
                                    throw Exception(
                                        "Error ${res.statusCode}: ${res.reasonPhrase}");
                                  }

                                  setState(() {
                                    _loading = false;
                                  });
                                  m.hideCurrentSnackBar();
                                  m.showSnackBar(SnackBar(
                                      content: Text(
                                          "Response Sent! [${res.statusCode}]")));
                                  Navigator.of(context).pushReplacement(
                                      createRoute(const PitScout()));
                                }).catchError((e) {
                                  m.hideCurrentSnackBar();
                                  setState(() {
                                    _loading = false;
                                  });
                                  m.showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                });
                              },
                              child: const Text("Submit")))
                    ])
                    .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        child: e))
                    .toList(),
              ))));

  // To satisfy dart use_build_context_synchronously in async functions
  void showSnackBar(SnackBar snackbar) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
