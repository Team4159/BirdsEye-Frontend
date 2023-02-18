import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/errorcontainer.dart';

enum PitScoutQuestionTypes { text }

class PitScout extends StatefulWidget {
  const PitScout({super.key});

  @override
  State<StatefulWidget> createState() => PitScoutState();
}

class PitScoutState extends State<PitScout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _fields = {};
  int? _teamNumber;
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
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: FutureBuilder(
                  future: stock.get(WebDataTypes.pitScout),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return snapshot.hasError
                          ? ErrorContainer(snapshot.error.toString())
                          : const Center(child: CircularProgressIndicator());
                    }
                    return ListView(
                        controller: _scrollController,
                        children: <Widget>[
                          TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLines: 1,
                              maxLength: 4,
                              validator: (value) => (value?.isNotEmpty ?? false)
                                  ? null
                                  : "Required",
                              decoration: const InputDecoration(
                                  labelText: "Team Number", counterText: ""),
                              onSaved: (String? content) {
                                _teamNumber = int.parse(content!);
                              })
                        ]
                            .followedBy(
                                snapshot.data!.entries.map((e) => TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration:
                                          InputDecoration(labelText: e.key),
                                      onSaved: (String? content) {
                                        _fields[e.value] = content ?? "";
                                      },
                                    )))
                            .followedBy([
                              ElevatedButton(
                                  onPressed: () {
                                    if (_loading) return;
                                    _fields.clear();
                                    if (!_formKey.currentState!.validate()) {
                                      _scrollController.animateTo(0,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeOutCubic);
                                      return;
                                    }
                                    _formKey.currentState!.save();
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
                                    postResponse(WebDataTypes.pitScout, {
                                      ..._fields,
                                      "teamNumber": _teamNumber,
                                      "name": prefs.getString("name")
                                    }).then((response) {
                                      _formKey.currentState!.reset();
                                      _teamNumber = null;
                                      m.hideCurrentSnackBar();
                                      setState(() {
                                        _loading = false;
                                      });
                                      _scrollController.animateTo(0,
                                          duration: const Duration(seconds: 1),
                                          curve: Curves.easeInOutQuad);
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
                  }))));
}
