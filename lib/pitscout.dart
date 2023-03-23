import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/resetbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PitScoutQuestionTypes { text }

class PitScout extends StatefulWidget {
  const PitScout({super.key});

  @override
  State<StatefulWidget> createState() => PitScoutState();
}

class PitScoutState extends State<PitScout> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<PitScoutTeamNumberFieldState> _teamNumberKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Pit Scouting"),
      ),
      drawer: AppDrawer(),
      body: Form(
          key: _formKey,
          child: FutureBuilder(
              future: stock.get(WebDataTypes.pitScout),
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
                        children: <Widget>[
                      Row(children: [
                        PitScoutTeamNumberField(key: _teamNumberKey),
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: ResetButton(reset: () {
                            _formKey.currentState!.reset();
                            _teamNumberKey.currentState!.reload();
                          }),
                        ))
                      ]),
                      const SizedBox(height: 10)
                    ]
                            .followedBy(
                                snapshot.data!.entries.map((e) => Material(
                                      type: MaterialType.card,
                                      elevation: 1,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.value,
                                                  textAlign: TextAlign.left,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge,
                                                  textScaleFactor: 1.2,
                                                ),
                                                const SizedBox(height: 10),
                                                TextFormField(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  maxLines: null,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 6,
                                                              horizontal: 8),
                                                      filled: true,
                                                      counterText: null,
                                                      border:
                                                          const OutlineInputBorder(),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]!))),
                                                  onSaved: (String? content) {
                                                    _fields[e.key] =
                                                        content ?? "";
                                                  },
                                                )
                                              ])),
                                    )))
                            .followedBy([
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if (_loading) return;
                                        _fields.clear();
                                        if (_teamNumberKey
                                                .currentState?.teamNumber ==
                                            null) {
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
                                        postResponse(WebDataTypes.pitScout, {
                                          ..._fields,
                                          "teamNumber": _teamNumberKey
                                              .currentState!.teamNumber,
                                          "name": prefs.getString("name")
                                        }).then((response) {
                                          if (response.statusCode >= 400) {
                                            throw Exception(
                                                "Error ${response.statusCode}: ${response.reasonPhrase}");
                                          }
                                          _formKey.currentState!.reset();
                                          _teamNumberKey.currentState!.reload();
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 6),
                                child: e))
                            .toList()));
              })));
}

class PitScoutTeamNumberField extends StatefulWidget {
  const PitScoutTeamNumberField({super.key});

  @override
  State<StatefulWidget> createState() => PitScoutTeamNumberFieldState();
}

class PitScoutTeamNumberFieldState extends State<PitScoutTeamNumberField> {
  TextEditingController? _controller;
  String? _errorText;
  int? teamNumber;
  static List<int> _acTeams = [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    _controller?.clear();
    _acTeams = [];
    pitScoutGetUnfilled().then((value) {
      value.sort();
      _acTeams = value;
    });
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 75, maxWidth: 150),
      child: Autocomplete(
          optionsBuilder: (TextEditingValue textEditingValue) => _acTeams.where(
              (element) =>
                  element.toString().startsWith(textEditingValue.text)),
          onSelected: (int content) => setState(() {
                teamNumber = content;
                _errorText = null;
              }),
          fieldViewBuilder: (BuildContext context,
              TextEditingController controller,
              FocusNode focusNode,
              VoidCallback onSubmitted) {
            _controller = controller;
            return TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    counterText: "",
                    labelText: "Team #",
                    errorText: _errorText),
                onSubmitted: (String content) {
                  onSubmitted();
                  teamNumber = null;
                  if (content.isEmpty) {
                    return setState(() => _errorText = "Required");
                  }
                  setState(() => _errorText = "Loading");
                  tbaStock
                      .get(
                          "${SettingsState.season}${prefs.getString('event')}_*")
                      .then((val) {
                    if (val.containsKey(content)) {
                      setState(() => _errorText = null);
                      teamNumber = int.parse(content);
                    } else {
                      setState(() => _errorText = "Invalid");
                      teamNumber = null;
                    }
                  });
                });
          }));
}
