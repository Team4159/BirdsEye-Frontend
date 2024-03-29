import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/matchformfields.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/resetbutton.dart';
import 'package:flutter/material.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScout extends StatefulWidget {
  const MatchScout({super.key});

  @override
  State<MatchScout> createState() => MatchScoutState();
}

class MatchScoutState extends State<MatchScout> {
  final GlobalKey<MatchInfoFieldsState> _matchInfoKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
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
                                                  onSaved: (content) =>
                                                      (_fields[e1.key] =
                                                              _fields[e1.key] ??
                                                                  {})[e2.key] =
                                                          content,
                                                );
                                              case MatchScoutQuestionTypes
                                                  .counter:
                                                return CounterFormField(
                                                    labelText: e2.key,
                                                    onSaved: (content) =>
                                                        (_fields[e1.key] =
                                                            _fields[e1.key] ??
                                                                {})[e2
                                                            .key] = content);
                                              case MatchScoutQuestionTypes
                                                  .toggle:
                                                return ToggleFormField(
                                                    labelText: e2.key,
                                                    onSaved: (content) =>
                                                        (_fields[e1.key] =
                                                            _fields[e1.key] ??
                                                                {})[e2
                                                            .key] = content);
                                              case MatchScoutQuestionTypes
                                                  .slider:
                                                return RatingFormField(
                                                  labelText: e2.key,
                                                  onSaved: (content) =>
                                                      (_fields[e1.key] =
                                                              _fields[e1.key] ??
                                                                  {})[e2.key] =
                                                          content,
                                                );
                                            }
                                          }), growable: false)))
                                ]))
                            .followedBy([
                          SliverPadding(
                              padding: const EdgeInsets.all(10),
                              sliver: SliverToBoxAdapter(
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(_loading
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
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
                                        setState(() => _loading = true);
                                        _formKey.currentState!.save();
                                        ScaffoldMessengerState m =
                                            ScaffoldMessenger.of(context)
                                              ..showSnackBar(const SnackBar(
                                                  duration:
                                                      Duration(minutes: 5),
                                                  behavior:
                                                      SnackBarBehavior.fixed,
                                                  elevation: 0,
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  content:
                                                      LinearProgressIndicator(
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
                                                "Error ${response.statusCode}: ${response.body}");
                                          }
                                          _formKey.currentState!.reset();
                                          _matchInfoKey.currentState!.reset();
                                          m.hideCurrentSnackBar();
                                          setState(() => _loading = false);
                                          _scrollController.animateTo(0,
                                              duration:
                                                  const Duration(seconds: 1),
                                              curve: Curves.easeInOutQuad);
                                          m.showSnackBar(SnackBar(
                                              content: Text(
                                                  "Response Sent! [${response.statusCode}]")));
                                        }).catchError((e) {
                                          setState(() => _loading = false);
                                          m
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                                content: Text(e.toString())));
                                        });
                                      },
                                      child: const Text("Submit"))))
                        ]).toList()));
              })));
}

class MatchInfoFields extends StatefulWidget {
  final void Function() reset;
  const MatchInfoFields({super.key, required this.reset});

  @override
  State<MatchInfoFields> createState() => MatchInfoFieldsState();
}

class MatchInfoFieldsState extends State<MatchInfoFields> {
  static final matchRobotIDregex = RegExp("(?<color>red|blue)(?<number>[1-3])");
  bool get isValid => matchCode != null && teamNumber != null;

  int? teamNumber;

  String? matchCode;
  final TextEditingController _matchCodeController = TextEditingController();
  String? _matchCodeError;

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
