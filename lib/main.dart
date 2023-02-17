import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'matchscout.dart';
import 'pitscout.dart';
import 'settings.dart';
import 'web.dart';

void main() async {
  prefs = await SharedPreferences.getInstance();
  runApp(MaterialApp(
      title: "Bird's Eye",
      initialRoute: "/",
      routes: {
        "/matchscout": (BuildContext context) => const MatchScout(),
        "/pitscout": (BuildContext context) => const PitScout(),
        "/": (BuildContext context) => MainScreen()
      },
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
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
          behavior: SnackBarBehavior.floating,
          closeIconColor: Colors.black,
          elevation: 3,
          contentTextStyle: TextStyle(
              fontFamily: "OpenSans",
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
                // AppBar Title
                fontFamily: "Verdana",
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 28),
            centerTitle: false),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xffcf2e2e), refreshBackgroundColor: Colors.black45),
        dividerTheme: const DividerThemeData(thickness: 4, indent: 0),
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

late SharedPreferences prefs;

getDrawer(context) => Drawer(
        child: ListView(
      children: [
        ListTile(
          title: Text(
            "Home",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.of(context).pushReplacement(_createRoute(MainScreen()));
          },
        ),
        ListTile(
          title: Text(
            "Match Scouting",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.of(context)
                .pushReplacement(_createRoute(const MatchScout()));
          },
        ),
        ListTile(
          title: Text(
            "Pit Scouting",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            Navigator.of(context)
                .pushReplacement(_createRoute(const PitScout()));
          },
        ),
      ],
    ));

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  final GlobalKey<SettingsState> _settingsKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Bird's Eye"),
        ),
        drawer: getDrawer(context),
        body: Settings(key: _settingsKey),
        floatingActionButton: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Cache",
            onPressed: () {
              cacheSoT.deleteAll();
              _settingsKey.currentState!.reloadEvents();
            }),
      );
}

Route _createRoute(Widget widget) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    });
