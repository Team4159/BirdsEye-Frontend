import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:birdseye/widgets/shfitingfit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SettingsState();
}

String serverIP = "scouting.team4159.org";

class SettingsState extends State<Settings> {
  List<MapEntry<String, dynamic>>? _events = [];
  static int season = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    reloadEvents();
  }

  void reloadEvents() {
    _events = [];
    tbaStock
        .get(SettingsState.season.toString())
        .then(
          (value) => setState(() {
            _events = value.entries.toList();
            var event = prefs.getString('event');
            _events!.sort(
              (a, b) => a.key == event
                  ? -1
                  : b.key == event
                      ? 1
                      : 0,
            );
          }),
        )
        .then(
      (_) {
        if (!prefs.containsKey("event") ||
            !_events!
                .any((element) => element.key == prefs.getString('event'))) {
          prefs.setString("event", _events![0].key);
        }
      },
    ).catchError((error) {
      if (mounted) {
        setState(() {
          _events = null;
        });
      } else {
        _events = null; // yeah whatever you deal with it
      }
    });
  }

  static InputDecoration inputDecoration(BuildContext context) =>
      InputDecoration(
          border: Theme.of(context).brightness == Brightness.light
              ? const UnderlineInputBorder()
              : InputBorder.none,
          counterText: '');

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Expanded(
            child: Column(children: [
          ShiftingFit(
              Text(
                "Current Season",
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.left,
              ),
              TextField(
                cursorColor: Colors.green[900],
                style: Theme.of(context).textTheme.bodySmall,
                maxLength: 4,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: inputDecoration(context),
                controller: TextEditingController(text: season.toString()),
                onSubmitted: (content) {
                  season = int.parse(content);
                },
              )),
          ShiftingFit(
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Name",
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.left,
                )),
            TextField(
              cursorColor: Colors.green[900],
              style: Theme.of(context).textTheme.bodySmall,
              maxLength: 64,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.name,
              decoration: inputDecoration(context),
              controller: TextEditingController(
                  text: prefs.getString("name") ?? "null"),
              onSubmitted: (value) {
                prefs.setString("name", value).then((value) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Set Name!"))));
              },
            ),
          ),
          const IPConfigField()
        ])),
        VerticalDivider(
          color: Theme.of(context).textTheme.labelSmall!.color,
          width: 24,
        ),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: _events == null
                    ? const ErrorContainer("Error")
                    : _events!.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ReorderableListView(
                            header: Text(
                              "Current Event",
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.left,
                            ),
                            shrinkWrap: true,
                            buildDefaultDragHandles: false,
                            proxyDecorator: (child, index, animation) =>
                                AnimatedBuilder(
                                    animation: animation,
                                    child: child,
                                    builder: (BuildContext context,
                                            Widget? child) =>
                                        Material(
                                          elevation: Curves.easeInOut
                                                  .transform(animation.value) *
                                              6,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          shadowColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          child: child,
                                        )),
                            onReorder: (int oldIndex, int newIndex) {
                              if (oldIndex < newIndex) {
                                newIndex--;
                              }
                              setState(() {
                                final item = _events!.removeAt(oldIndex);
                                _events!.insert(newIndex, item);
                                if (newIndex == 0) {
                                  prefs.setString("event", item.key);
                                }
                              });
                            },
                            children: [
                                for (int i = 0; i < _events!.length; i++)
                                  ReorderableDragStartListener(
                                      key: ValueKey(_events![i].key),
                                      index: i,
                                      child: ListTile(
                                        onTap: () async {
                                          await prefs.setString(
                                              "event", _events![i].key);
                                          var event = _events![i].key;
                                          setState(() {
                                            _events!.sort(
                                              (a, b) => a.key == event
                                                  ? -1
                                                  : b.key == event
                                                      ? 1
                                                      : 0,
                                            );
                                          });
                                        },
                                        title: Text(
                                          _events![i].value,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          textAlign: TextAlign.right,
                                          style: _events![i].key ==
                                                  prefs.getString('event')
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w800)
                                              : Theme.of(context)
                                                  .textTheme
                                                  .displaySmall,
                                        ),
                                        trailing: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                minWidth: 60, maxWidth: 60),
                                            child: Text(_events![i].key,
                                                textAlign: TextAlign.right,
                                                style: _events![i].key ==
                                                        prefs.getString('event')
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w900)
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                      ))
                              ]))),
      ]));
}

class IPConfigField extends StatefulWidget {
  const IPConfigField({super.key});

  @override
  State<StatefulWidget> createState() => IPConfigFieldState();
}

class IPConfigFieldState extends State<IPConfigField> {
  final _controller = TextEditingController(text: serverIP);
  bool _enabled = true;

  @override
  Widget build(BuildContext context) => ShiftingFit(
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Server IP",
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.left,
            )),
        TextField(
          enabled: _enabled,
          cursorColor: Colors.green[900],
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.right,
          maxLines: 1,
          maxLength: 64,
          keyboardType: TextInputType.url,
          controller: _controller,
          textCapitalization: TextCapitalization.none,
          decoration: SettingsState.inputDecoration(context),
          onSubmitted: (content) {
            setState(() {
              _enabled = false;
            });
            getStatus(content).then((value) {
              if (value) {
                serverIP = content;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Set IP!")));
              } else {
                _controller.text = serverIP;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Invalid IP!")));
              }
              setState(() {
                _enabled = true;
              });
            });
          },
        ),
      );
}
