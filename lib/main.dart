import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'matchscout.dart';
import 'pitscout.dart';
import 'web.dart';

void main() async {
  prefs = await SharedPreferences.getInstance();
  runApp(MaterialApp(
      title: "Bird's Eye",
      initialRoute: "/",
      routes: {
        "/matchscout": (BuildContext context) => const MatchScout(),
        "/pitscout": (BuildContext context) => const PitScout(),
        "/": (BuildContext context) => const MainScreen()
      },
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
            primary: Colors.blue[600]!,
            surface: const Color(0xffcf2e2e),
            background: Colors.black),
        scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(1),
            trackVisibility: MaterialStateProperty.all(true)),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
        snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating, closeIconColor: Colors.black),
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
                // AppBar Title
                fontFamily: "Verdana",
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 28)),
        textTheme: TextTheme(
            displayLarge: const TextStyle(
              // Match Scout Section Titles
              fontFamily: "VarelaRound",
              fontSize: 36,
              letterSpacing: 5,
              fontWeight: FontWeight.w900,
            ),
            displaySmall: TextStyle(
                // Settings Option List
                fontFamily: "OpenSans",
                fontSize: 16,
                fontWeight: FontWeight.w200,
                color: Colors.green[700]),
            labelMedium: const TextStyle(
              // Drawer Items
              fontFamily: "Verdana",
              fontSize: 20,
            ),
            labelSmall: TextStyle(
                // Settings Title
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2,
                color: Colors.green[700]),
            bodyMedium: const TextStyle(
                // Form Field Titles & Hover Tooltips
                fontFamily: "OpenSans",
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.white70),
            bodySmall: TextStyle(
                // Settings Input
                fontFamily: "Calibri",
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.green[700])),
        scaffoldBackgroundColor: Colors.black,
      )));
}

SharedPreferences? prefs;
String serverIP = "10.66.70.169:5000";

getDrawer(context) => Drawer(
        // TODO: Nested Navigation https://stackoverflow.com/questions/66755344/flutter-navigation-push-while-keeping-the-same-appbar
        child: ListView(
      children: [
        ListTile(
          title: Text(
            "Home",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.of(context).popAndPushNamed("/");
          },
        ),
        ListTile(
          title: Text(
            "Match Scouting",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.of(context).popAndPushNamed("/matchscout");
          },
        ),
        ListTile(
          title: Text(
            "Pit Scouting",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.of(context).popAndPushNamed("/pitscout");
          },
        ),
      ],
    ));

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text("Bird's Eye"),
        ),
        drawer: getDrawer(context),
        body: const Settings(),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: "Refresh Cache",
          onPressed: cacheSoT.deleteAll,
        ),
      );
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  static num season = DateTime.now().year;
  static String event = "casf";

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Stack(
          alignment: Alignment.center,
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
              onSubmitted: (value) {
                season = int.parse(value);
              },
            )
          ],
        ),
        Stack(alignment: Alignment.center, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Team Number",
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
            controller: TextEditingController(
                text: (prefs!.getInt("teamNumber") ?? 4159).toString()),
            onSubmitted: (value) {
              prefs!.setInt("teamNumber", int.parse(value)).then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Set Team Number!"))));
            },
          ),
        ]),
        Stack(
          alignment: Alignment.center,
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
                  text: prefs!.getString("name") ?? "NoName"),
              onSubmitted: (value) {
                prefs!.setString("name", value).then((value) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Set Name!"))));
              },
            )
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Server IP",
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.left,
                )),
            TextField(
              cursorColor: Colors.green[900],
              style: Theme.of(context).textTheme.bodySmall,
              maxLength: 24,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                  border: InputBorder.none, counterText: ''),
              controller: TextEditingController(text: serverIP),
              onSubmitted: (value) {
                serverIP = value;
              },
            )
          ],
        ),
        Stack(alignment: Alignment.topCenter, children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.centerLeft,
              child: Text(
                "Current Event",
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.left,
              )),
          Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: FutureBuilder(
                      future: stock.get(WebDataTypes.currentEvents),
                      builder: (context, snapshot) {
                        final e = snapshot.data?.entries.toList();
                        if (e == null) {
                          return ErrorContainer(snapshot.error.toString());
                        }
                        int i = e.indexWhere((element) => element.key == event);
                        MapEntry<String, dynamic>? se =
                            i >= 0 ? e.removeAt(i) : null;
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: (se != null
                                    ? <ListTile>[
                                        ListTile(
                                          title: Text(
                                            se.value,
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                          trailing: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  minWidth: 60, maxWidth: 60),
                                              child: Text(se.key,
                                                  textAlign: TextAlign.right,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontWeight: FontWeight
                                                              .w900))),
                                        )
                                      ]
                                    : <ListTile>[])
                                .followedBy(e.map((e) => ListTile(
                                      title: Text(
                                        e.value,
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
                                      ),
                                      trailing: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              minWidth: 60, maxWidth: 60),
                                          child: Text(e.key,
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600))),
                                      onTap: () {
                                        setState(() {
                                          SettingsState.event = e.key;
                                        });
                                      },
                                    )))
                                .toList());
                      })))
        ])
      ]));
}
