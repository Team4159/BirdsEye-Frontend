import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
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
          autovalidateMode: AutovalidateMode.disabled,
          child: FutureBuilder(
              future: stock.get(WebDataTypes.pitScout),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return snapshot.hasError
                      ? ErrorContainer(snapshot.error)
                      : const Center(child: CircularProgressIndicator());
                }
                return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    controller: _scrollController,
                    children: <Widget>[
                      Row(children: [
                        const PitScoutTeamNumberField(),
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[800]),
                            tooltip: "Reset",
                            onPressed: () {
                              _formKey.currentState!.reset();
                              _teamNumberKey.currentState!.refreshAC();
                            },
                          ),
                        ))
                      ])
                    ]
                        .followedBy(
                            snapshot.data!.entries.map((e) => TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey[700]!)),
                                      labelText: e.key),
                                  onSaved: (String? content) {
                                    _fields[e.value] = content ?? "";
                                  },
                                )))
                        .followedBy([
                          ElevatedButton(
                              onPressed: () {
                                if (_loading) return;
                                _fields.clear();
                                if (!_formKey.currentState!.validate() ||
                                    _teamNumberKey.currentState?.teamNumber ==
                                        null) {
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
                                  "teamNumber":
                                      _teamNumberKey.currentState!.teamNumber,
                                  "name": prefs.getString("name")
                                }).then((response) {
                                  if (response.statusCode >= 400) {
                                    throw Exception(
                                        "Error ${response.statusCode}: ${response.reasonPhrase}");
                                  }
                                  _formKey.currentState!.reset();
                                  _teamNumberKey.currentState!.refreshAC();
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
                                  m.showSnackBar(
                                      SnackBar(content: Text(e.toString())));
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
              })));
}

class PitScoutTeamNumberField extends StatefulWidget {
  const PitScoutTeamNumberField({super.key});

  @override
  State<StatefulWidget> createState() => PitScoutTeamNumberFieldState();
}

class PitScoutTeamNumberFieldState extends State<PitScoutTeamNumberField> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  String _lGoodTeamNumber = "";
  String _lBadTeamNumber = "";
  int? teamNumber;
  static List<int> _acTeams = [];

  @override
  void initState() {
    super.initState();
    refreshAC();
  }

  void refreshAC() {
    _lGoodTeamNumber = "";
    _key.currentState?.reset();
    pitScoutGetUnfilled().then((value) {
      value.sort();
      _acTeams = value;
    });
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 75, maxWidth: 150),
      child: Autocomplete(
          fieldViewBuilder: (BuildContext context,
                  TextEditingController controller,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) =>
              TextFormField(
                key: _key,
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                textInputAction: TextInputAction.done,
                decoration:
                    const InputDecoration(labelText: "Team #", counterText: ""),
                validator: (String? content) {
                  if (content == null || content.isEmpty) {
                    return "Required";
                  }
                  if (_lGoodTeamNumber == content) return null;
                  if (_lBadTeamNumber == content) {
                    return "Invalid";
                  }
                  tbaStock
                      .get(
                          "${SettingsState.season}${prefs.getString('event')}_*")
                      .then((val) {
                    if (val.containsKey(content)) {
                      _lGoodTeamNumber = content;
                      teamNumber = int.parse(content);
                    } else {
                      _lBadTeamNumber = content;
                      teamNumber = null;
                    }
                    _key.currentState!.validate();
                  });
                  return "Validating";
                },
                onFieldSubmitted: (String content) {
                  _key.currentState!.validate();
                  onFieldSubmitted();
                },
                onChanged: (String value) {
                  _lGoodTeamNumber = "";
                  teamNumber = null;
                },
              ),
          optionsBuilder: (TextEditingValue textEditingValue) => _acTeams.where(
              (element) =>
                  element.toString().startsWith(textEditingValue.text))));
}
