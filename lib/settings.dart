import 'package:flutter/material.dart';
import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDetails {
  static String? name;
  static int? team;
  static bool get isAuthenticated =>
      Supabase.instance.client.auth.currentUser != null;
  static String get id => Supabase.instance.client.auth.currentUser?.id ?? "0";

  static Future update() => Supabase.instance.client
          .from("users")
          .select<Map<String, dynamic>?>('name, team')
          .eq('id', id)
          .maybeSingle()
          .then((value) {
        if (value == null) throw Exception("No User Found");
        name = value['name'];
        team = value['team'];
      }).catchError((e) {
        name = team = null;
        throw e;
      });
  static bool get isValid =>
      isAuthenticated &&
      name != null &&
      team != null &&
      prefs.containsKey("tbaKey") &&
      prefs.getString("tbaKey") != null;
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();

  static Future showConfigDialog(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        GlobalKey<FormState> formKey = GlobalKey();
        String? name = UserDetails.name;
        int? team = UserDetails.team;
        return FractionallySizedBox(
            heightFactor: 0.6,
            child: Dialog(
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Form(
                        key: formKey,
                        child: Column(children: [
                          Text("Modify User Info",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge),
                          TextFormField(
                            initialValue: name,
                            decoration:
                                const InputDecoration(labelText: "Name"),
                            onSaved: (String? value) => name = value,
                          ),
                          TextFormField(
                            initialValue: team.toString(),
                            decoration: const InputDecoration(
                                labelText: "Team", counterText: ""),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 4,
                            onSaved: (String? value) =>
                                team = int.tryParse(value ?? ""),
                          ),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.always,
                            obscureText: true,
                            initialValue: prefs.getString("tbaKey"),
                            decoration: const InputDecoration(
                                labelText: "TBA API Key", counterText: ""),
                            maxLength: 64,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : value.length != 64
                                    ? "Wrong Length"
                                    : null,
                            onSaved: (String? value) =>
                                prefs.setString("tbaKey", value ?? ""),
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        formKey.currentState!.save();
                                        Supabase.instance.client
                                            .from("users")
                                            .update(<String, dynamic>{
                                              if (name != null) "name": name,
                                              if (team != null) "team": team
                                            })
                                            .eq("id", UserDetails.id)
                                            .then((_) => UserDetails.update())
                                            .then((_) {
                                              if (UserDetails.isValid) {
                                                Navigator.of(context).pop();
                                              }
                                            })
                                            .catchError((e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content:
                                                          Text(e.toString())));
                                            }); // FIXME doesnt update
                                      },
                                      child: Text("Submit",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary)))))
                        ])))));
      });
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
        .then((value) => setState(() => _events = value.entries.toList()))
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
  Widget build(BuildContext context) {
    if (!UserDetails.isValid) Settings.showConfigDialog(context);
    return Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FutureBuilder(
              future: Supabase.instance.client
                  .rpc("getavailableseasons")
                  .then((resp) => List<int>.from(resp as Iterable)),
              builder: (BuildContext ctx, AsyncSnapshot<List<int>> snapshot) =>
                  !snapshot.hasData
                      ? const Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator())
                      : CarouselSlider(
                          items: snapshot.data!
                              .map((year) => Text(year.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium))
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
                                      .map<Widget>((event) => ListTile(
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
                                                          fontWeight: FontWeight
                                                              .w500)))))
                                      .toList(),
                                  options: CarouselOptions(
                                      aspectRatio: 1 / 5,
                                      viewportFraction: 0.1,
                                      scrollDirection: Axis.vertical,
                                      initialPage: _events!.indexWhere(
                                          (element) =>
                                              element.key ==
                                              prefs.getString('event')),
                                      onPageChanged: (i, _) => prefs.setString(
                                          'event', _events![i].key))),
                              GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: IgnorePointer(
                                      child: Center(
                                          child: Container(
                                    constraints: const BoxConstraints.tightFor(
                                        height: 40),
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(top: 10),
                                    color: Colors.grey.withAlpha(100),
                                  ))))
                            ]))
        ]));
  }
}
