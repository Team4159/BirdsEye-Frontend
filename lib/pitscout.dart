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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Pit Scouting"),
      ),
      drawer: getDrawer(context),
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
                    children: <Widget>[const PitInfoFields()]
                        .followedBy(
                            snapshot.data!.entries.map((e) => TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(labelText: e.key),
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
                                    PitInfoFieldsState._teamNumber == null) {
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
                                  "teamNumber": PitInfoFieldsState._teamNumber,
                                  "name": prefs.getString("name")
                                }).then((response) {
                                  if (response.statusCode >= 400) {
                                    throw Exception(
                                        "Error ${response.statusCode}");
                                  }
                                  _formKey.currentState!.reset();
                                  PitInfoFieldsState._teamNumber = null;
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

class PitInfoFields extends StatefulWidget {
  const PitInfoFields({super.key});

  @override
  State<StatefulWidget> createState() => PitInfoFieldsState();
}

class PitInfoFieldsState extends State<PitInfoFields> {
  static int? _teamNumber;
  final GlobalKey<FormFieldState> _teamNumberKey = GlobalKey<FormFieldState>();
  String _lGoodTeamNumber = "";
  String _lBadTeamNumber = "";

  @override
  Widget build(BuildContext context) => ConstrainedBox(
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
          if (_lGoodTeamNumber == content) return null;
          if (_lBadTeamNumber == content) return "Invalid";
          tbaStock
              .get("${SettingsState.season}${prefs.getString('event')}_*")
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
      ));
}
