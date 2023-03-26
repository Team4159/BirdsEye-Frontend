import 'package:birdseye/main.dart';
import 'package:birdseye/matchscoutteamassignment.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/counterformfield.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/resetbutton.dart';
import 'package:birdseye/widgets/sliderformfield.dart';
import 'package:birdseye/widgets/stextformfield.dart';
import 'package:birdseye/widgets/toggleformfield.dart';
import 'package:flutter/material.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScout extends StatefulWidget {
  MatchScout({super.key, required this.teamNumber, required this.matchId});

  int teamNumber;
  String matchId;

  @override
  State<StatefulWidget> createState() => MatchScoutState();
}

class MatchScoutState extends State<MatchScout> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<MatchInfoFieldsState> _matchInfoKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final Map<String, Map<String, dynamic>> _fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      drawer: AppDrawer(),
      body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                const SliverAppBar(
                  title: Text("Match Scouting"),
                  centerTitle: false,
                  floating: true,
                  snap: true,
                )
              ],
          body: FutureBuilder(
              future: stock.get(WebDataTypes.matchScout),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return snapshot.hasError
                      ? ErrorContainer(snapshot.error)
                      : const Center(child: CircularProgressIndicator());
                }
                return Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: CustomScrollView(
                        cacheExtent: double.infinity,
                        slivers: <Widget>[
                          SliverPadding(
                              padding: const EdgeInsets.all(15),
                              sliver: SliverToBoxAdapter(
                                  child: MatchInfoFields(
                                      teamNumber: widget.teamNumber,
                                      matchCode: widget.matchId,
                                      key: _matchInfoKey,
                                      reset: () =>
                                          _formKey.currentState!.reset())))
                        ]
                            .followedBy(snapshot.data!.entries.expand((e1) => [
                                  SliverAppBar(
                                      primary: false,
                                      automaticallyImplyLeading: false,
                                      centerTitle: true,
                                      backgroundColor: Colors.transparent,
                                      elevation: 1,
                                      title: Text(
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? e1.key
                                              : e1.key.toUpperCase()),
                                      titleTextStyle: Theme.of(context)
                                          .textTheme
                                          .displayMedium),
                                  SliverPadding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, bottom: 15),
                                      sliver: SliverGrid.count(
                                          childAspectRatio: 3 / 1,
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          children: List.from(
                                              e1.value.entries.map((e2) {
                                            switch (MatchScoutQuestionTypes
                                                .values
                                                .byName(e2.value)) {
                                              case MatchScoutQuestionTypes.text:
                                                return STextFormField(
                                                  labelText: e2.key,
                                                  onSaved: (content) {
                                                    if (!_fields
                                                        .containsKey(e1.key)) {
                                                      _fields[e1.key] = {};
                                                    }

                                                    _fields[e1.key]![e2.key] =
                                                        content;
                                                  },
                                                );
                                              case MatchScoutQuestionTypes
                                                  .counter:
                                                return CounterFormField(
                                                    labelText: e2.key,
                                                    onSaved: (content) {
                                                      if (!_fields.containsKey(
                                                          e1.key)) {
                                                        _fields[e1.key] = {};
                                                      }

                                                      _fields[e1.key]![e2.key] =
                                                          content;
                                                    });
                                              case MatchScoutQuestionTypes
                                                  .toggle:
                                                return ToggleFormField(
                                                    labelText: e2.key,
                                                    onSaved: (content) {
                                                      if (!_fields.containsKey(
                                                          e1.key)) {
                                                        _fields[e1.key] = {};
                                                      }

                                                      _fields[e1.key]![e2.key] =
                                                          content;
                                                    });
                                              case MatchScoutQuestionTypes
                                                  .slider:
                                                return SliderFormField(
                                                  labelText: e2.key,
                                                  onSaved: (content) {
                                                    if (!_fields
                                                        .containsKey(e1.key)) {
                                                      _fields[e1.key] = {};
                                                    }

                                                    _fields[e1.key]![e2.key] =
                                                        content?.toInt();
                                                  },
                                                );
                                            }
                                          }), growable: false)))
                                ]))
                            .followedBy([
                          SliverPadding(
                              padding: const EdgeInsets.all(10),
                              sliver: SliverToBoxAdapter(
                                  child: Row(
                                children: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          enableFeedback: !_loading),
                                      onPressed: () {
                                        if (_loading) return;
                                        _fields.clear();
                                        if (!_matchInfoKey
                                            .currentState!.isValid) {
                                          _scrollController.animateTo(0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeOutCubic);
                                          return;
                                        }
                                        setState(() {
                                          _loading = true;
                                        });
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
                                        postResponse(WebDataTypes.matchScout, {
                                          ..._fields,
                                          "teamNumber": _matchInfoKey
                                              .currentState!.teamNumber,
                                          "match": _matchInfoKey
                                              .currentState!.matchCode,
                                          "name": prefs.getString("name")
                                        }).then((response) {
                                          if (response.statusCode >= 400) {
                                            throw Exception(
                                                "Error ${response.statusCode}: ${response.reasonPhrase}");
                                          }
                                          _formKey.currentState!.reset();
                                          _matchInfoKey.currentState!.reset();
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MatchScoutTeamAssignment()));
                                        }).catchError((e) {
                                          m.hideCurrentSnackBar();
                                          setState(() {
                                            _loading = false;
                                          });
                                          m.showSnackBar(SnackBar(
                                              content: Text(e.toString())));
                                        });
                                      },
                                      child: const Text("Submit")),
                                  ElevatedButton(
                                      onPressed: () {
                                        if (_loading) return;
                                        _fields.clear();
                                        if (!_matchInfoKey
                                            .currentState!.isValid) {
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
                                        // Free the original team assignment rather than the new team assignment
                                        freeScoutingAssignment(widget.matchId,
                                                widget.teamNumber)
                                            .then((response) {
                                          setState(() {
                                            _loading = false;
                                          });
                                          if (response.statusCode >= 400) {
                                            throw Exception(
                                                "Error ${response.statusCode}: ${response.reasonPhrase}");
                                          }

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MatchScoutTeamAssignment()));
                                        }).catchError((error) {
                                          m.hideCurrentSnackBar();
                                          setState(() {
                                            _loading = false;
                                          });
                                          m.showSnackBar(SnackBar(
                                              content: Text(error.toString())));
                                        });
                                        postResponse(WebDataTypes.matchScout, {
                                          ..._fields,
                                          "teamNumber": _matchInfoKey
                                              .currentState!.teamNumber,
                                          "match": _matchInfoKey
                                              .currentState!.matchCode,
                                          "name": prefs.getString("name")
                                        }).then((response) {
                                          if (response.statusCode >= 400) {
                                            throw Exception(
                                                "Error ${response.statusCode}: ${response.reasonPhrase}");
                                          }
                                          _formKey.currentState!.reset();
                                          _matchInfoKey.currentState!.reset();
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MatchScoutTeamAssignment()));
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
                                          : const Text("Cancel"))
                                ],
                              )))
                        ]).toList()));
              })));
}

class MatchInfoFields extends StatefulWidget {
  final void Function() reset;
  final String matchCode;
  final int teamNumber;

  const MatchInfoFields(
      {super.key,
      required this.reset,
      required this.matchCode,
      required this.teamNumber});

  @override
  State<StatefulWidget> createState() => MatchInfoFieldsState();
}

class MatchInfoFieldsState extends State<MatchInfoFields> {
  static final matchRobotIDregex = RegExp("(?<color>red|blue)(?<number>[1-3])");
  bool get isValid => matchCode != null && teamNumber != null;

  int? teamNumber;

  String? matchCode;
  final TextEditingController _matchCodeController = TextEditingController();
  String? _matchCodeError;

  @override
  void initState() {
    super.initState();

    matchCode = widget.matchCode;
    teamNumber = widget.teamNumber;
    _matchCodeController.text = widget.matchCode;
  }

  void reset() {
    _matchCodeController.clear();
    setState(() => teamNumber = matchCode = null);
    widget.reset();
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                constraints: const BoxConstraints(
                    maxWidth: 100,
                    minHeight: kMinInteractiveDimension * 1.2,
                    maxHeight: kMinInteractiveDimension * 1.2),
              )),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TextField(
                controller: _matchCodeController,
                keyboardType: TextInputType.text,
                maxLength: 5,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    counterText: "",
                    hintText: "Match Code",
                    errorText: _matchCodeError),
                onSubmitted: (String content) {
                  setState(() => teamNumber = matchCode = null);

                  if (content.isEmpty) {
                    return setState(() => _matchCodeError = "Required");
                  }
                  setState(() => _matchCodeError = "Loading");
                  tbaStock
                      .get("${SettingsState.season}${prefs.getString('event')}")
                      .then((val) {
                    if (val.containsKey(content)) {
                      setState(() {
                        _matchCodeError = null;
                        matchCode = content;
                      });
                    } else {
                      setState(() {
                        _matchCodeError = "Invalid";
                        teamNumber = matchCode = null;
                      });
                    }
                  });
                }),
            const SizedBox(width: 15),
            FutureBuilder(
                future: matchCode == null
                    ? null
                    : tbaStock
                        .get(
                            "${SettingsState.season}${prefs.getString('event')}_$matchCode")
                        .then((data) {
                        final out = data.entries
                            .map((e) => MapEntry<int, String>(
                                int.parse(e.key), e.value))
                            .toList();
                        out.sort((a, b) => a.value.compareTo(b.value));
                        return Map.fromEntries(out);
                      }),
                builder: (context, snapshot) => DropdownButton<int>(
                      hint: const Text("Team #"),
                      value: teamNumber,
                      items: snapshot.data?.entries.map((e) {
                            final match = matchRobotIDregex.firstMatch(e.value);
                            if (match == null) {
                              throw Exception(
                                  "Invalid Match Robot Identifier!");
                            }
                            return DropdownMenuItem<int>(
                                value: e.key,
                                child: Text(
                                    "${match.namedGroup('number')} | ${e.key}",
                                    style: TextStyle(
                                        backgroundColor: frcColors[
                                            match.namedGroup("color")])));
                          }).toList() ??
                          [],
                      onChanged: (content) => setState(() => teamNumber =
                          matchCode != null &&
                                  snapshot.data != null &&
                                  snapshot.data!.containsKey(content)
                              ? content
                              : null),
                    )),
            Expanded(child: ResetButton(reset: reset))
          ]));
}
