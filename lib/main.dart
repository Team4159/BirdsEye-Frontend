import 'package:birdseye/matchscout.dart';
import 'package:birdseye/pitscout.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const cardinalred = Color(0xffcf2e2e);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  if (prefs.getString("ip") == null) {
    prefs.setString("ip", "scouting.team4159.org");
  }
  runApp(MaterialApp(
    title: "Bird's Eye",
    initialRoute: "/",
    routes: {
      "/matchscout": (BuildContext context) => const MatchScout(),
      "/pitscout": (BuildContext context) => const PitScout(),
      "/": (BuildContext context) => MainScreen()
    },
    color: cardinalred,
    themeMode: ThemeMode.system,
    darkTheme: ThemeData(
      colorScheme: ColorScheme.dark(
          primary: Colors.blue[600]!,
          secondary: Colors.transparent,
          surface: cardinalred,
          background: Colors.black),
      scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(1),
          trackVisibility: MaterialStateProperty.all(true)),
      inputDecorationTheme:
          const InputDecorationTheme(border: OutlineInputBorder()),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey,
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
          color: cardinalred, refreshBackgroundColor: Colors.black45),
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
        titleLarge: const TextStyle(
            // CardinalBotics Logo Theme
            fontFamily: "HemiHead",
            fontSize: 32,
            color: cardinalred),
        labelMedium: const TextStyle(
          // Drawer Items
          fontFamily: "Verdana",
          fontSize: 20,
        ),
        labelSmall: TextStyle(
            // Settings Labels
            fontFamily: "RobotoMono",
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
            color: Colors.green[700]),
        bodySmall: TextStyle(
            // Settings Input
            fontFamily: "Calibri",
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.green[700]),
        bodyMedium: const TextStyle(
            // Form Field Titles & Hover Tooltips
            fontFamily: "OpenSans",
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.white70),
      ),
      scaffoldBackgroundColor: Colors.black,
    ),
    theme: ThemeData(
      colorScheme: ColorScheme.light(
          primary: Colors.blue[600]!,
          secondary: Colors.grey[400]!,
          surface: cardinalred,
          background: Colors.grey[200]!),
      scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(1),
          trackVisibility: MaterialStateProperty.all(true)),
      inputDecorationTheme:
          const InputDecorationTheme(border: OutlineInputBorder()),
      appBarTheme: const AppBarTheme(
          color: cardinalred,
          titleTextStyle: TextStyle(
              // AppBar Title
              fontFamily: "Verdana",
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 28),
          centerTitle: true),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[200]),
      textTheme: const TextTheme(
        titleLarge:
            TextStyle(fontFamily: "HemiHead", fontSize: 32, color: cardinalred),
        labelSmall: TextStyle(
            // Settings Labels
            fontFamily: "OpenSans",
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1),
        labelMedium: TextStyle(
          // Drawer Items
          fontFamily: "Verdana",
          fontSize: 20,
        ),
        displayLarge: TextStyle(
            // Match Scout Section Titles
            fontFamily: "VarelaRound",
            fontSize: 36,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.black),
        displaySmall: TextStyle(
            // Settings Option List
            fontFamily: "OpenSans",
            fontSize: 16,
            fontWeight: FontWeight.w200),
        bodySmall: TextStyle(
            // Settings Input
            fontFamily: "Calibri",
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black54),
      ),
    ),
  ));
}

late SharedPreferences prefs;

getDrawer(context) => Drawer(
    width: 200,
    child: Column(
      children: [
        SizedBox(
            height: 65,
            child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Bird's Eye",
                  style: Theme.of(context).textTheme.titleLarge,
                ))),
        ListTile(
          title: Text(
            "Configuration",
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
          title: const Text("Configuration"),
        ),
        drawer: getDrawer(context),
        body: Settings(key: _settingsKey),
        floatingActionButton: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Cache",
            onPressed: () {
              stock.clearAll();
              tbaStock.clearAll();
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
