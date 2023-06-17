import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  List<MapEntry<String, dynamic>>? _events = [];
  static int season = DateTime.now().year;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
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
        setState(() => _events = null);
      } else {
        _events = null; // yeah whatever you deal with it
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        Widget a = TextField(
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: const InputDecoration(
              counterText: "", suffixText: "Current Season"),
          maxLength: 4,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: TextEditingController(text: season.toString()),
          onSubmitted: (content) {
            season = int.parse(content);
            stock.clearAll();
            reload();
          },
        );
        Widget b =
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text("Current Event",
              style: const InputDecorationTheme().hintStyle,
              textAlign: TextAlign.right),
          const SizedBox(height: 20),
          _events == null
              ? Center(
                  child: Icon(Icons.warning_rounded,
                      color: Colors.red[700], size: 50))
              : _events!.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView(
                          controller: _controller,
                          shrinkWrap: true,
                          children: [
                          for (int i = 0; i < _events!.length; i++)
                            ListTile(
                                visualDensity:
                                    VisualDensity.adaptivePlatformDensity,
                                onTap: () async {
                                  await prefs.setString(
                                      "event", _events![i].key);
                                  HapticFeedback.selectionClick();
                                  _controller.animateTo(0,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeOutCubic);
                                  var event = _events![i].key;
                                  setState(() => _events!.sort(
                                        (a, b) => a.key == event
                                            ? -1
                                            : b.key == event
                                                ? 1
                                                : 0,
                                      ));
                                },
                                title: Text(
                                  _events![i].value,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: _events![i].key ==
                                          prefs.getString('event')
                                      ? Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontWeight: FontWeight.w800)
                                      : Theme.of(context).textTheme.titleMedium,
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
                                              .titleSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.w900)
                                          : Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.w500)),
                                ))
                        ]))
        ]);
        if (constraints.maxWidth > 500) {
          return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: a),
                const SizedBox(width: 40),
                Expanded(child: b)
              ]);
        } else {
          return Column(
              children: [a, const SizedBox(height: 40), Expanded(child: b)]);
        }
      }));
}
