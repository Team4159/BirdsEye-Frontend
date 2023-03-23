import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/counterformfield.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/resetbutton.dart';
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
                        slivers: <Widget>[
                      SliverPadding(
                          padding: const EdgeInsets.all(15),
                          sliver: SliverToBoxAdapter(
                              child: MatchInfoFields(
                                  key: _matchInfoKey,
                                  reset: () => _formKey.currentState!.reset())))
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
                                                return TextFormField(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  maxLines: null,
                                                  expands: true,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets.only(
                                                              bottom: 4,
                                                              top: 10,
                                                              left: 10,
                                                              right: 10),
                                                      counterText: null,
                                                      border:
                                                          const OutlineInputBorder(),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]!)),
                                                      labelText: e2.key),
                                                  onSaved: (String? content) {
                                                    _fields[e1.key] =
                                                        _fields[e1.key] ?? {};

                                                    _fields[e1.key]![e2.key] =
                                                        content;
                                                  },
                                                );
                                              case MatchScoutQuestionTypes
                                                  .counter:
                                                return CounterFormField(
                                                    initialValue: 0,
                                                    labelText: e2.key,
                                                    onSaved: (int? content) {
                                                      _fields[e1.key] =
                                                          _fields[e1.key] ?? {};

                                                      _fields[e1.key]![e2.key] =
                                                          content;
                                                    });
                                              case MatchScoutQuestionTypes
                                                  .toggle:
                                                return ToggleFormField(
                                                    labelText: e2.key,
                                                    onSaved: (bool? content) {
                                                      _fields[e1.key] =
                                                          _fields[e1.key] ?? {};

                                                      _fields[e1.key]![e2.key] =
                                                          content;
                                                    });
                                              case MatchScoutQuestionTypes
                                                  .slider:
                                                return SliderFormField(
                                                    labelText: e2.key,
                                                    onSaved:
                                                        (double? contentd) {
                                                      _fields[e1.key] =
                                                          _fields[e1.key] ?? {};

                                                      int? content =
                                                          contentd?.toInt();
                                                      _fields[e1.key]![e2.key] =
                                                          content;
                                                    });
                                            }
                                          }), growable: false)))
                                ]))
                            .followedBy([
                      SliverPadding(
                          padding: const EdgeInsets.all(10),
                          sliver: SliverToBoxAdapter(
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (_loading) return;
                                    _fields.clear();
                                    if (!_matchInfoKey.currentState!.isValid) {
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
                                    postResponse(WebDataTypes.matchScout, {
                                      ..._fields,
                                      "teamNumber": _matchInfoKey
                                          .currentState!.teamNumber,
                                      "match":
                                          _matchInfoKey.currentState!.matchCode,
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
                                          duration: const Duration(seconds: 1),
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
                                  child: const Text("Submit"))))
                    ]).toList()));
              })));
}

class MatchInfoFields extends StatefulWidget {
  final void Function() reset;
  const MatchInfoFields({super.key, required this.reset});

  @override
  State<StatefulWidget> createState() => MatchInfoFieldsState();
}

class MatchInfoFieldsState extends State<MatchInfoFields> {
  bool get isValid => matchCode != null && teamNumber != null;

  int? teamNumber;
  TextEditingController? _teamNumberController;
  String? _teamNumberError;

  String? matchCode;
  final TextEditingController _matchCodeController = TextEditingController();
  String? _matchCodeError;

  void reset() {
    _teamNumberController?.clear();
    _matchCodeController.clear();
    widget.reset();
  }

  @override
  Widget build(BuildContext context) => Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: 95,
              child: TextField(
                  controller: _matchCodeController,
                  keyboardType: TextInputType.text,
                  maxLength: 5,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      counterText: "",
                      labelText: "Match Code",
                      errorText: _matchCodeError),
                  onSubmitted: (String content) {
                    matchCode = null;

                    if (content.isEmpty) {
                      return setState(() => _matchCodeError = "Required");
                    }
                    setState(() => _matchCodeError = "Loading");
                    tbaStock
                        .get(
                            "${SettingsState.season}${prefs.getString('event')}")
                        .then((val) {
                      if (val.containsKey(content)) {
                        setState(() => _matchCodeError = null);
                        matchCode = content;
                        _teamNumberController?.clear();
                      } else {
                        setState(() => _matchCodeError = "Invalid");
                        matchCode = null;
                      }
                    });
                  }),
            ),
            const SizedBox(width: 15),
            SizedBox(
                width: 75,
                child: Autocomplete(
                    optionsBuilder: (textEditingValue) => matchCode == null
                        ? Future<Iterable<int>>.value([])
                        : tbaStock
                            .get(
                                "${SettingsState.season}${prefs.getString('event')}_$matchCode")
                            .then((val) => val.keys
                                .where((element) => element
                                    .toString()
                                    .startsWith(textEditingValue.text))
                                .map((e) => int.parse(e))),
                    onSelected: (int content) => setState(() {
                          teamNumber = content;
                          _teamNumberError = null;
                        }),
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      _teamNumberController = controller;
                      return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 4,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              counterText: "",
                              labelText: "Team #",
                              errorText: _teamNumberError),
                          onSubmitted: (String content) {
                            teamNumber = null;

                            onFieldSubmitted();
                            if (content.isEmpty) {
                              return setState(
                                  () => _teamNumberError = "Required");
                            }
                            if (matchCode == null || matchCode!.isEmpty) {
                              return setState(() {
                                _teamNumberError = "No Match";
                                _matchCodeError = "Required";
                              });
                            }
                            setState(() => _teamNumberError = "Loading");
                            tbaStock
                                .get(
                                    "${SettingsState.season}${prefs.getString('event')}_$matchCode")
                                .then((val) {
                              if (val.containsKey(content)) {
                                setState(() => _teamNumberError = null);
                                teamNumber = int.parse(content);
                              } else {
                                setState(() => _teamNumberError = "Invalid");
                                teamNumber = null;
                              }
                            });
                          });
                    })),
            Expanded(child: ResetButton(reset: reset))
          ]);
}
