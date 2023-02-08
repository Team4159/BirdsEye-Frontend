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
String event = "casf"; // TODO: Create Event Selector
num season = DateTime.now().year;
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

class Settings extends StatelessWidget {
  const Settings({super.key});

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
                  "Current Event",
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.left,
                )),
            TextField(
              cursorColor: Colors.green[900],
              style: Theme.of(context).textTheme.bodySmall,
              maxLength: 12,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  border: InputBorder.none, counterText: ''),
              controller: TextEditingController(text: event),
              onSubmitted: (value) {
                event = value;
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
      ]));
}

const double buttonBaseline = 36;
