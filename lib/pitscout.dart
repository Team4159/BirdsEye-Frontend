import 'package:birdseye/main.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/resetbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PitSchema = Map<String, String>;
// ID: Question

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

  void reset() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    _teamNumberKey.currentState!.reload();
    _teamNumber = null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Pit Scouting")),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: Future.value({
            "comments_generic": "Comments Generic" // TODO figure out pit stuff
          }), //stock.get(WebDataTypes.pitScout)
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(children: [
                        PitScoutTeamNumberField(
                            key: _teamNumberKey,
                            onSubmitted: (int? teamNumber) =>
                                setState(() => _teamNumber = teamNumber)),
                        IconButton(
                            onPressed: () {
                              if (_teamNumber == null) return;
                              Supabase.instance.client
                                  .from("${SettingsState.season}_pit")
                                  .select<Map<String, dynamic>?>()
                                  .eq("event", prefs.getString('event'))
                                  .eq("scouter", UserDetails.id)
                                  .eq("team", _teamNumber)
                                  .maybeSingle()
                                  .then((Map<String, dynamic>? data) =>
                                      (data ?? <String, String>{})
                                        ..removeWhere((k, v) =>
                                            {"event", "scouter", "team"}
                                                .contains(k) ||
                                            v is! String ||
                                            v.isEmpty))
                                  .then((vals) {
                                if (vals.isEmpty) return;
                                for (final entry in _controllers.entries) {
                                  if (vals.containsKey(entry.key) &&
                                      vals[entry.key] != null) {
                                    entry.value.text +=
                                        (entry.value.text.isEmpty ? "" : "\n") +
                                            vals[entry.key]!.toString();
                                  }
                                }
                              });
                            },
                            icon: const Icon(Icons.save_as),
                            alignment: AlignmentDirectional.topStart,
                            tooltip: "Load Previous Responses",
                            color: _teamNumber != null
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
                        .followedBy(snapshot.data!.entries.map((e) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.value,
                                    textAlign: TextAlign.left,
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                    textScaleFactor: 1.2,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                      controller: (_controllers[e.key] =
                                          _controllers[e.key] ??
                                              TextEditingController()),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        counterText: "",
                                      ))
                                ]))))
                        .followedBy([
                      ElevatedButton(
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
                            Supabase.instance.client
                                .from("${SettingsState.season}_pit")
                                .upsert({
                              ..._controllers.map((k, v) =>
                                  MapEntry<String, String>(k, v.text)),
                              "event": prefs.getString('event'),
                              "team": _teamNumber
                            }).then((_) {
                              reset();
                              m.hideCurrentSnackBar();
                              setState(() => _loading = false);
                              _scrollController.animateTo(0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOutQuad);
                              m.showSnackBar(const SnackBar(
                                  content: Text("Response Sent!")));
                            }).catchError((e) {
                              setState(() => _loading = false);
                              m
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                    content: Text(e is PostgrestException
                                        ? e.message
                                        : e.toString())));
                            });
                          },
                          child: Text("Submit",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)))
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
        return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    constraints:
                        const BoxConstraints(minWidth: 75, maxWidth: 150),
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
                      .get(
                          "${SettingsState.season}${prefs.getString('event')}_*")
                      .then((val) {
                    if (val.containsKey(content)) {
                      setState(() => _errorText = null);
                      widget.onSubmitted(int.parse(content));
                    } else {
                      setState(() => _errorText = "Invalid");
                      widget.onSubmitted(null);
                    }
                  });
                }));
      });
}
