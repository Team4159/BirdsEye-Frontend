import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/counterformfield.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/sliderformfield.dart';
import 'package:birdseye/widgets/toggleformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScout extends StatefulWidget {
  const MatchScout({super.key});

  @override
  State<StatefulWidget> createState() => MatchScoutState();
}

class MatchScoutState extends State<MatchScout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
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
          autovalidateMode: AutovalidateMode.disabled,
          child: FutureBuilder(
              future: stock.get(WebDataTypes.matchScout),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return snapshot.hasError
                      ? ErrorContainer(snapshot.error)
                      : const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    controller: _scrollController,
                    child: Column(
                        children: <Widget>[const MatchInfoFields()]
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
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? e1.key
                                        : e1.key.toUpperCase(),
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
                                                .validate() ||
                                            !MatchInfoFieldsState.isValid) {
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
                                          "name": prefs.getString("name")
                                        }).then((response) {
                                          if (response.statusCode >= 400) {
                                            throw Exception(
                                                "Error ${response.statusCode}: ${response.reasonPhrase}");
                                          }
                                          _formKey.currentState!.reset();
                                          m.hideCurrentSnackBar();
                                          setState(() {
                                            _loading = false;
                                          });
                                          _scrollController.animateTo(0,
                                              duration:
                                                  const Duration(seconds: 1),
                                              curve: Curves.easeInOutQuad);
                                          m.showSnackBar(SnackBar(
                                              content: Text(
                                                  "Response Sent! [${response.statusCode}]")));
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
  static bool get isValid => _matchCode != null && _teamNumber != null;

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
                key: _matchCodeKey,
                keyboardType: TextInputType.text,
                maxLength: 5,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Match Code",
                    counterText: ""),
                validator: (String? content) {
                  if (content == null || content.isEmpty) return "Required";
                  if (_lGoodMatchCode == content) return null;
                  if (_lBadMatchCode == content) return "Invalid";
                  tbaStock
                      .get("${SettingsState.season}${prefs.getString('event')}")
                      .then((val) {
                    if (val.containsKey(content)) {
                      _lGoodMatchCode = content;
                      _matchCode = content;
                      _lBadTeamNumber = _lGoodTeamNumber = "";
                      _teamNumberKey.currentState!.validate();
                    } else {
                      _lBadMatchCode = content;
                      _matchCode = null;
                    }
                    _matchCodeKey.currentState!.validate();
                  });
                  return "Validating";
                },
                onFieldSubmitted: (String content) {
                  _matchCodeKey.currentState!.validate();
                },
                onChanged: (String value) {
                  if (value != _matchCode.toString()) _matchCode = null;
                },
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 75, maxWidth: 150),
                child: TextFormField(
                  key: _teamNumberKey,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Team #",
                      counterText: ""),
                  validator: (String? content) {
                    if (content == null || content.isEmpty) return "Required";
                    if (_matchCode == null || _matchCode!.isEmpty) {
                      return "Set Match First!";
                    }
                    if (_lGoodTeamNumber == content) return null;
                    if (_lBadTeamNumber == content) return "Invalid";
                    tbaStock
                        .get(
                            "${SettingsState.season}${prefs.getString('event')}_$_matchCode")
                        .then((val) {
                      if (val.containsKey(content)) {
                        _lGoodTeamNumber = content;
                        _teamNumber = int.parse(content);
                      } else {
                        _lBadTeamNumber = content;
                        _teamNumber = null;
                      }
                      _teamNumberKey.currentState!.validate();
                    });
                    return "Validating";
                  },
                  onFieldSubmitted: (String content) {
                    _teamNumberKey.currentState!.validate();
                  },
                  onChanged: (String value) {
                    if (value != _teamNumber.toString()) _teamNumber = null;
                  },
                ))
          ]);
}
