import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'web.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

String serverIP = "localhost:5000";

class SettingsState extends State<Settings> {
  List<MapEntry<String, dynamic>>? _events;
  static num season = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    stock
        .get(WebDataTypes.currentEvents)
        .then(
          (value) => setState(() {
            _events = value.entries.toList();
            var event = prefs.getString("event");
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
                .any((element) => element.key == prefs.getString("event"))) {
          prefs.setString("event", _events![0].key);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Expanded(
            child: Column(children: [
          Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Current Season",
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.left,
                  )),
              TextField(
                cursorColor: Colors.green[900],
                style: Theme.of(context).textTheme.bodySmall,
                maxLength: 4,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    border: InputBorder.none, counterText: ''),
                controller: TextEditingController(text: season.toString()),
                onSubmitted: (content) {
                  season = int.parse(content);
                },
              )
            ],
          ),
          Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
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
                decoration: const InputDecoration(
                    border: InputBorder.none, counterText: ''),
                controller: TextEditingController(
                    text: prefs.getString("name") ?? "NoName"),
                onSubmitted: (value) {
                  prefs.setString("name", value).then((value) =>
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Set Name!"))));
                },
              )
            ],
          ),
          const IPConfigField()
        ])),
        VerticalDivider(
          color: Theme.of(context).textTheme.labelSmall!.color,
          width: 24,
        ),
        Expanded(
            child: Stack(fit: StackFit.expand, children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.topLeft,
              child: Text(
                "Current Event",
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.left,
              )),
          Builder(builder: (context) {
            if (_events == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.topRight,
                child: ReorderableListView(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex--;
                        }
                        final item = _events!.removeAt(oldIndex);
                        _events!.insert(newIndex, item);
                        if (newIndex == 0) prefs.setString("event", item.key);
                      });
                    },
                    children: [
                      for (int i = 0; i < _events!.length; i++)
                        ReorderableDragStartListener(
                            key: ValueKey(_events![i].key),
                            index: i,
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  prefs.setString("event", _events![i].key);
                                });
                              },
                              title: Text(
                                _events![i].value,
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                textAlign: TextAlign.right,
                                style: _events![i].key ==
                                        prefs.getString("event")
                                    ? Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontWeight: FontWeight.w800)
                                    : Theme.of(context).textTheme.displaySmall,
                              ),
                              trailing: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minWidth: 60, maxWidth: 60),
                                  child: Text(_events![i].key,
                                      textAlign: TextAlign.right,
                                      style: _events![i].key ==
                                              prefs.getString("event")
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.w900)
                                          : Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.w500))),
                            ))
                    ]));
          })
        ]))
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
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
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
            maxLength: 24,
            keyboardType: TextInputType.url,
            controller: _controller,
            textCapitalization: TextCapitalization.none,
            decoration: const InputDecoration(
                border: InputBorder.none, counterText: ''),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid IP!")));
                }
                setState(() {
                  _enabled = true;
                });
              });
            },
          )
        ],
      );
}
