import 'package:flutter/material.dart';
import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  List<MapEntry<String, dynamic>>? _events = [];
  static int season = DateTime.now().year;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FutureBuilder(
            future: Supabase.instance.client
                .rpc("getavailableseasons")
                .then((resp) => List<int>.from(resp as Iterable)),
            builder: (BuildContext ctx, AsyncSnapshot<List<int>> snapshot) =>
                !snapshot.hasData
                    ? const LinearProgressIndicator()
                    : CarouselSlider(
                        items: snapshot.data!
                            .map((year) => Text(year.toString(),
                                style:
                                    Theme.of(context).textTheme.headlineMedium))
                            .toList(),
                        options: CarouselOptions(
                            aspectRatio: 12 / 1,
                            viewportFraction: 0.4,
                            enableInfiniteScroll: false,
                            onPageChanged: (i, _) {
                              season = snapshot.data![i];
                              reload();
                            }))),
        const SizedBox(height: 30),
        Expanded(
            child: _events == null
                ? Center(
                    child: Icon(Icons.warning_rounded,
                        color: Colors.red[700], size: 50))
                : _events!.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.center,
                        children: [
                            CarouselSlider(
                                items: _events!
                                    .map((event) => ListTile(
                                        visualDensity:
                                            VisualDensity.comfortable,
                                        title: Text(
                                          event.value,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                        trailing: IntrinsicWidth(
                                            child: Text(event.key,
                                                textAlign: TextAlign.right,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500)))))
                                    .toList(),
                                options: CarouselOptions(
                                    aspectRatio: 1 / 5,
                                    viewportFraction: 0.1,
                                    scrollDirection: Axis.vertical,
                                    onPageChanged: (i, _) {
                                      prefs.setString('event', _events![i].key);
                                    })),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: IgnorePointer(
                                child: Center(
                                    child: Container(
                                  constraints:
                                      const BoxConstraints.tightFor(height: 40),
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(top: 10),
                                  color: Colors.grey.withAlpha(100),
                                )),
                              ),
                            ),
                          ]))
      ]));
}
