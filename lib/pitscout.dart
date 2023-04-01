import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/resetbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitScout extends StatefulWidget {
  const PitScout({super.key});

  @override
  State<PitScout> createState() => PitScoutState();
}

class PitScoutState extends State<PitScout> {
  final GlobalKey<PitScoutTeamNumberFieldState> _teamNumberKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  int? _teamNumber;
  bool _loading = false;
  bool _editing = false;

  void reset() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    _teamNumberKey.currentState!.reload();
    _teamNumber = null;
    _editing = false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Pit Scouting")),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: stock.get(WebDataTypes.pitScout),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return snapshot.hasError
                  ? ErrorContainer(snapshot.error)
                  : const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                controller: _scrollController,
                child: Column(
                    children: <Widget>[
                  Row(children: [
                    PitScoutTeamNumberField(
                        key: _teamNumberKey,
                        onSubmitted: (int? teamNumber) =>
                            setState(() => _teamNumber = teamNumber)),
                    IconButton(
                        onPressed: () {
                          if (_teamNumber == null ||
                              prefs.getString("name") == null) return;
                          pitScoutGetMyResponse(_teamNumber!).then((vals) {
                            for (final entry in _controllers.entries) {
                              if (vals[entry.key] != null &&
                                  !entry.value.text
                                      .contains(vals[entry.key]!)) {
                                entry.value.text +=
                                    (entry.value.text.isNotEmpty ? "\n" : "") +
                                        vals[entry.key]!;
                              }
                            }
                            _editing = true;
                          });
                        },
                        icon: const Icon(Icons.save_as),
                        alignment: AlignmentDirectional.topStart,
                        tooltip: "Load Previous Responses",
                        color: _teamNumber != null &&
                                prefs.getString("name") != null
                            ? Colors.green
                            : Colors.grey),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: ResetButton(reset: reset),
                    ))
                  ]),
                  const SizedBox(height: 10)
                ]
                        .followedBy(snapshot.data!.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Material(
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
                                          TextField(
                                              controller: (_controllers[e.key] =
                                                  _controllers[e.key] ??
                                                      TextEditingController()),
                                              keyboardType: TextInputType
                                                  .multiline,
                                              maxLines: null,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 6,
                                                          horizontal: 8),
                                                  filled: true,
                                                  counterText: "",
                                                  border:
                                                      const OutlineInputBorder(),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]!))))
                                        ]))))))
                        .followedBy([
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  _loading
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.primary)),
                          onPressed: () {
                            if (_loading) return;
                            if (_teamNumber == null) {
                              _scrollController.animateTo(0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic);
                              return;
                            }
                            ScaffoldMessengerState m =
                                ScaffoldMessenger.of(context)
                                  ..showSnackBar(const SnackBar(
                                      duration: Duration(minutes: 5),
                                      behavior: SnackBarBehavior.fixed,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      content: LinearProgressIndicator(
                                        backgroundColor: Colors.transparent,
                                      )));
                            setState(() => _loading = true);
                            postResponse(
                                    WebDataTypes.pitScout,
                                    {
                                      ..._controllers.map((k, v) =>
                                          MapEntry<String, String>(k, v.text)),
                                      "teamNumber": _teamNumber,
                                      "name": prefs.getString("name")
                                    },
                                    patch: _editing)
                                .then((response) {
                              if (response.statusCode >= 400) {
                                throw Exception(
                                    "Error ${response.statusCode}: ${response.body}");
                              }
                              reset();
                              m.hideCurrentSnackBar();
                              setState(() => _loading = false);
                              _scrollController.animateTo(0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOutQuad);
                              m.showSnackBar(SnackBar(
                                  content: Text(
                                      "Response Sent! [${response.statusCode}]")));
                            }).catchError((e) {
                              setState(() => _loading = false);
                              m
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                            });
                          },
                          child: const Text("Submit")))
                ]).toList()));
          }));
}

class PitScoutTeamNumberField extends StatefulWidget {
  final void Function(int? teamNumber) onSubmitted;
  const PitScoutTeamNumberField({super.key, required this.onSubmitted});

  @override
  State<PitScoutTeamNumberField> createState() =>
      PitScoutTeamNumberFieldState();
}

class PitScoutTeamNumberFieldState extends State<PitScoutTeamNumberField> {
  TextEditingController? _controller;
  String? _errorText;
  static List<int> _acTeams = [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    _controller?.clear();
    _acTeams = [];
    pitScoutGetUnfilled().then((value) =>
        mounted ? setState(() => _acTeams = value) : (_acTeams = value));
  }

  @override
  Widget build(BuildContext context) => Autocomplete(
      optionsBuilder: (TextEditingValue textEditingValue) => _acTeams.where(
          (element) => element.toString().startsWith(textEditingValue.text)),
      onSelected: (int content) => setState(() {
            widget.onSubmitted(content);
            _errorText = null;
          }),
      fieldViewBuilder: (BuildContext context, TextEditingController controller,
          FocusNode focusNode, VoidCallback onSubmitted) {
        _controller = controller;
        return TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 4,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                constraints: const BoxConstraints(minWidth: 75, maxWidth: 150),
                counterText: "",
                labelText: "Team #",
                errorText: _errorText),
            onSubmitted: (String content) {
              onSubmitted();
              widget.onSubmitted(null);
              if (content.isEmpty) {
                return setState(() => _errorText = "Required");
              }
              setState(() => _errorText = "Loading");
              tbaStock
                  .get("${SettingsState.season}${prefs.getString('event')}_*")
                  .then((val) {
                if (val.containsKey(content)) {
                  setState(() => _errorText = null);
                  widget.onSubmitted(int.parse(content));
                } else {
                  setState(() => _errorText = "Invalid");
                  widget.onSubmitted(null);
                }
              });
            });
      });
}
