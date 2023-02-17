import 'package:birdseye/widgets/counterformfield.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/sliderformfield.dart';
import 'package:birdseye/widgets/toggleformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'settings.dart';
import 'web.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScout extends StatefulWidget {
  const MatchScout({super.key});

  @override
  State<StatefulWidget> createState() => MatchScoutState();
}

class MatchScoutState extends State<MatchScout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final MatchInfoFields matchInfoFields = const MatchInfoFields();
  final Map<String, Map<String, dynamic>> _fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Match Scouting"),
      ),
      drawer: getDrawer(context),
      body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: FutureBuilder(
              future: stock.get(WebDataTypes.matchScout),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return snapshot.hasError
                      ? ErrorContainer(snapshot.error.toString())
                      : const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    controller: _scrollController,
                    child: Column(
                        children: <Widget>[matchInfoFields]
                            .followedBy(snapshot.data!.entries.map((e1) {
                              Iterable<MapEntry<String, dynamic>> a = e1
                                  .value.entries
                                  .where((e) => MatchScoutQuestionTypes.values
                                      .any((t) => t.name == e.value));
                              return Column(children: [
                                Container(
                                  alignment: Alignment.topCenter,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    e1.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                  ),
                                ),
                                GridView.count(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            expands: true,
                                            decoration: InputDecoration(
                                                labelText: e2.key),
                                            onSaved: (String? content) {
                                              _fields[e1.key] =
                                                  _fields[e1.key] ?? {};

                                              _fields[e1.key]![e2.key] =
                                                  content;
                                            },
                                          );
                                        case MatchScoutQuestionTypes.counter:
                                          return CounterFormField(
                                              initialValue: 0,
                                              labelText: e2.key,
                                              onSaved: (int? content) {
                                                _fields[e1.key] =
                                                    _fields[e1.key] ?? {};

                                                _fields[e1.key]![e2.key] =
                                                    content;
                                              });
                                        case MatchScoutQuestionTypes.toggle:
                                          return ToggleFormField(
                                              labelText: e2.key,
                                              onSaved: (bool? content) {
                                                _fields[e1.key] =
                                                    _fields[e1.key] ?? {};

                                                _fields[e1.key]![e2.key] =
                                                    content;
                                              });
                                        case MatchScoutQuestionTypes.slider:
                                          return SliderFormField(
                                              labelText: e2.key,
                                              onSaved: (double? contentd) {
                                                _fields[e1.key] =
                                                    _fields[e1.key] ?? {};

                                                int? content =
                                                    contentd?.toInt();
                                                _fields[e1.key]![e2.key] =
                                                    content;
                                              });
                                      }
                                    }).toList())
                              ]);
                            }))
                            .followedBy([
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if (_loading) return;
                                        _fields.clear();
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          _scrollController.animateTo(0,
                                              duration: const Duration(
                                                  milliseconds: 200),
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
                                              backgroundColor:
                                                  Colors.transparent,
                                            )));
                                        setState(() {
                                          _loading = true;
                                        });
                                        postResponse(WebDataTypes.matchScout, {
                                          "form": _fields,
                                          "teamNumber":
                                              MatchInfoFieldsState._teamNumber,
                                          "match":
                                              MatchInfoFieldsState._matchCode,
                                        }).then((response) {
                                          _formKey.currentState!.reset();
                                          MatchInfoFieldsState._teamNumber =
                                              null;
                                          MatchInfoFieldsState._matchCode =
                                              null;
                                          m.hideCurrentSnackBar();
                                          setState(() {
                                            _loading = false;
                                          });
                                          _scrollController.animateTo(0,
                                              duration:
                                                  const Duration(seconds: 1),
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
                                          : const Text("Submit")))
                            ])
                            .map((e) => Padding(
                                padding: const EdgeInsets.all(15), child: e))
                            .toList()));
              })));
}

class MatchInfoFields extends StatefulWidget {
  const MatchInfoFields({super.key});

  @override
  State<StatefulWidget> createState() => MatchInfoFieldsState();
}

class MatchInfoFieldsState extends State<MatchInfoFields> {
  static int? _teamNumber;
  final GlobalKey<FormFieldState> _teamNumberKey = GlobalKey<FormFieldState>();
  String _lGoodTeamNumber = "";
  String _lBadTeamNumber = "";

  static String? _matchCode;
  final GlobalKey<FormFieldState> _matchCodeKey = GlobalKey<FormFieldState>();
  String _lGoodMatchCode = "";
  String _lBadMatchCode = "";

  @override
  Widget build(BuildContext context) => Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
              child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLength: 3,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Match Code",
                      counterText: ""),
                  validator: (String? content) {
                    if (content == null || content.isEmpty) return "Required";
                    var tn = _matchCode.toString();
                    if (_lGoodMatchCode == tn) return null;
                    if (_lBadMatchCode == tn) return "Invalid";
                    tbaStock
                        .get("${SettingsState.season}${prefs.get('event')}")
                        .then((val) {
                      if (val.containsKey(content)) {
                        _lGoodMatchCode = content;
                      } else {
                        _lBadMatchCode = content;
                      }
                      _matchCodeKey.currentState!.validate();
                    });
                    return "Validating";
                  },
                  onFieldSubmitted: (String? content) {
                    _matchCode = content;
                  }),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 75, maxWidth: 150),
                child: TextFormField(
                    key: _teamNumberKey,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Team #",
                        counterText: ""),
                    validator: (String? content) {
                      if (content == null || content.isEmpty) return "Required";
                      if (_matchCode == null) return "Set Match First!";
                      var tn = _teamNumber.toString();
                      if (_lGoodTeamNumber == tn) return null;
                      if (_lBadTeamNumber == tn) return "Invalid";
                      tbaStock
                          .get(
                              "${SettingsState.season}${prefs.get('event')}_$_matchCode")
                          .then((val) {
                        if (val.containsKey(content)) {
                          _lGoodTeamNumber = content;
                        } else {
                          _lBadTeamNumber = content;
                        }
                        _teamNumberKey.currentState!.validate();
                      });
                      return "Validating";
                    },
                    onFieldSubmitted: (String? content) {
                      _teamNumber = int.parse(content!);
                    }))
          ]);
}
