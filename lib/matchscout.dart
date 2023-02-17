import 'dart:convert';

import 'package:birdseye/widgets/counterformfield.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/sliderformfield.dart';
import 'package:birdseye/widgets/toggleformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

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
  final GlobalKey<FormFieldState> _teamNumberTextFormFieldKey =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _matchCodeTextFormFieldKey =
      GlobalKey<FormFieldState>();
  int? _teamNumber;
  String? _matchCode;
  bool _loading = false;
  String _lastValidiatedTeamNumber = "";
  String _lastRejectedTeamNumber = "";
  String _lastValidiatedMatchCode = "";
  String _lastRejectedMatchCode = "";
  bool _isMatchCodeValid = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Match Scouting"),
      ),
      drawer: getDrawer(context),
      body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
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
                    child: Column(
                        children: <Widget>[
                      Row(children: [
                        ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 70),
                            child: TextFormField(
                                key: _teamNumberTextFormFieldKey,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                maxLines: 1,
                                maxLength: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Required";
                                  }

                                  String? validation =
                                      validateTeamNumber(value);

                                  if (validation == null) {
                                    _teamNumberTextFormFieldKey.currentState
                                        ?.save();
                                  }

                                  return validation;
                                }, // TODO: Validate this Field (match endpoint)
                                decoration: const InputDecoration(
                                    labelText: "Team #", counterText: ""),
                                onSaved: (String? content) {
                                  _teamNumber = int.parse(content!);
                                })),
                        Expanded(
                            child: TextFormField(
                          key: _matchCodeTextFormFieldKey,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            _lastValidiatedTeamNumber = "";
                            _lastRejectedTeamNumber = "";

                            if (value == null || value.isEmpty) {
                              _isMatchCodeValid = false;
                              _teamNumberTextFormFieldKey.currentState
                                  ?.validate();
                              return "Required";
                            }

                            String? validation = validateMatchCode(value);
                            _isMatchCodeValid = validation == null;

                            if (validation == null) {
                              _matchCodeTextFormFieldKey.currentState?.save();
                            }

                            _teamNumberTextFormFieldKey.currentState
                                ?.validate();
                            return validation;
                          },
                          maxLines: 1,
                          maxLength: 3,
                          decoration: const InputDecoration(
                              labelText: "Match Code", counterText: ""),
                          onSaved: (String? content) {
                            _matchCode = content;
                          },
                        ))
                      ])
                    ]
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
                                              fields[e1.key] =
                                                  fields[e1.key] ?? {};

                                              fields[e1.key]![e2.key] = content;
                                            },
                                          );
                                        case MatchScoutQuestionTypes.counter:
                                          return CounterFormField(
                                              initialValue: 0,
                                              labelText: e2.key,
                                              onSaved: (int? content) {
                                                fields[e1.key] =
                                                    fields[e1.key] ?? {};

                                                fields[e1.key]![e2.key] =
                                                    content;
                                              });
                                        case MatchScoutQuestionTypes.toggle:
                                          return ToggleFormField(
                                              labelText: e2.key,
                                              onSaved: (bool? content) {
                                                fields[e1.key] =
                                                    fields[e1.key] ?? {};

                                                fields[e1.key]![e2.key] =
                                                    content;
                                              });
                                        case MatchScoutQuestionTypes.slider:
                                          return SliderFormField(
                                              labelText: e2.key,
                                              onSaved: (double? contentd) {
                                                fields[e1.key] =
                                                    fields[e1.key] ?? {};

                                                int? content =
                                                    contentd?.toInt();
                                                fields[e1.key]![e2.key] =
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
                                        fields.clear();
                                        if (!formKey.currentState!.validate())
                                          // ignore: curly_braces_in_flow_control_structures
                                          return;
                                        formKey.currentState!.save();
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
                                          "form": fields,
                                          "teamNumber": _teamNumber,
                                          "match": _matchCode
                                        }).then((response) {
                                          formKey.currentState!.reset();
                                          _teamNumber = null;
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
                                          : const Text("Submit")))
                            ])
                            .map((e) => Padding(
                                padding: const EdgeInsets.all(15), child: e))
                            .toList()));
              })));

  // Prereq: Ensure teamNumber is not ""
  String? validateTeamNumber(String teamNumber) {
    // TODO fix validation when switching matches
    if (_matchCode == null || !_isMatchCodeValid) {
      return "Enter valid match code first";
    } else if (_lastValidiatedTeamNumber == teamNumber) {
      return null;
    } else if (_lastRejectedTeamNumber == teamNumber) {
      return "Invalid team number";
    } else {
      initiateAsyncTeamNumberValidation(teamNumber);
      return "Validating team number...";
    }
  }

  // Prereq: Ensure _matchCode is not null
  Future<void> initiateAsyncTeamNumberValidation(String teamNumber) async {
    final Response res =
        await getResponse(WebDataTypes.matchScoutEventMatchTeams, _matchCode);

    final List<dynamic> teamList = jsonDecode(res.body);

    if (teamList.contains("frc$teamNumber")) {
      _lastValidiatedTeamNumber = teamNumber;
    } else {
      _lastRejectedTeamNumber = teamNumber;
    }

    _teamNumberTextFormFieldKey.currentState?.validate();
  }

  // Prereq: Ensure matchCode is not ""
  String? validateMatchCode(String matchCode) {
    if (_lastValidiatedMatchCode == matchCode) {
      return null;
    } else if (_lastRejectedMatchCode == matchCode) {
      return "Invalid match code";
    } else {
      initiateAsyncMatchCodeValidation(matchCode);
      return "Validating match code...";
    }
  }

  Future<void> initiateAsyncMatchCodeValidation(String matchCode) async {
    final Response res = await getResponse(WebDataTypes.matchScoutEventMatches);
    final List<dynamic> matchList = jsonDecode(res.body);

    if (matchList
        .contains("${SettingsState.season}${SettingsState.event}_$matchCode")) {
      _lastValidiatedMatchCode = matchCode;
    } else {
      _lastRejectedMatchCode = matchCode;
    }

    _matchCodeTextFormFieldKey.currentState?.validate();
  }
}
