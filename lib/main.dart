import 'package:birdseye/matchscout.dart';
import 'package:birdseye/pitscout.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const cardinalred = Color(0xffcf2e2e);
final frcColors = {
  "red": const Color(0xffed1c24),
  "blue": const Color(0xff0066b3)
};
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await Supabase.initialize(
    url: 'https://zcckkiwosxzupxblocff.supabase.co',
    anonKey: const String.fromEnvironment('SUPABASE_KEY',
        defaultValue:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjY2traXdvc3h6dXB4YmxvY2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODY4NDk3MzMsImV4cCI6MjAwMjQyNTczM30.IVIT9yIxQ9JiwbDB6v10ZI8eP7c1oQhwoWZejoODllQ"),
  );
  // await Supabase.instance.client.auth.signInWithOAuth(Provider.github,
  //     authScreenLaunchMode: LaunchMode.externalNonBrowserApplication);
  runApp(
    MaterialApp(
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
        colorScheme: const ColorScheme.dark(
            secondaryContainer: Color(0xff1C7C7C),
            tertiaryContainer: Color(0xffCF772E),
            surface: cardinalred),
        inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.white12,
            border: const UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[350]!))),
        snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            elevation: 3,
            backgroundColor: Colors.grey),
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
                fontFamily: "Verdana",
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 28),
            centerTitle: false),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: cardinalred, refreshBackgroundColor: Colors.black45),
        dividerTheme: const DividerThemeData(thickness: 3),
        sliderTheme: const SliderThemeData(
            valueIndicatorColor: Colors.white60,
            valueIndicatorTextStyle: TextStyle(
                fontFamily: "Roboto", fontSize: 16, color: Colors.black)),
        textTheme: Typography.whiteHelsinki
            .merge(Typography.englishLike2021)
            .apply(
                bodyColor: Colors.white,
                displayColor: Colors.grey[300],
                fontFamilyFallback: [
              "Arial",
              "Calibri"
            ]).copyWith(
                titleLarge: const TextStyle(fontFamily: "Verdana"),
                displaySmall: const TextStyle(
                    fontFamily: "OpenSans", color: Colors.black),
                displayMedium: const TextStyle(
                    fontFamily: "VarelaRound", letterSpacing: 2, fontSize: 48)),
        cardColor: Colors.grey[700]!,
        scaffoldBackgroundColor: Colors.black,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.light(
            primary: Colors.blue[600]!,
            secondary: Colors.grey[400]!,
            secondaryContainer: const Color(0xff1C7C7C),
            tertiaryContainer: const Color(0xffCF772E),
            surface: cardinalred,
            background: Colors.grey[300]!),
        inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.black12,
            border: const UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!))),
        appBarTheme: const AppBarTheme(
            backgroundColor: cardinalred,
            titleTextStyle: TextStyle(
                fontFamily: "Verdana",
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28),
            centerTitle: true),
        textTheme: Typography.blackCupertino
            .merge(Typography.englishLike2021)
            .apply(
                bodyColor: Colors.black,
                displayColor: Colors.white,
                fontFamilyFallback: [
              "Arial",
              "Calibri"
            ]).copyWith(
                titleLarge: const TextStyle(fontFamily: "Verdana"),
                displaySmall: const TextStyle(fontFamily: "OpenSans"),
                displayMedium: const TextStyle(
                    fontFamily: "VarelaRound", letterSpacing: 2, fontSize: 48)),
        cardColor: Colors.grey[400],
        scaffoldBackgroundColor: Colors.grey[100]!,
      ),
    ),
  );
}

late SharedPreferences prefs;

class AppDrawer extends Builder {
  AppDrawer({super.key})
      : super(
            builder: (context) => Drawer(
                width: 200,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 75,
                        child: DrawerHeader(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Bird's Eye",
                              style: TextStyle(
                                  fontFamily: "HemiHead",
                                  fontSize: 32,
                                  color: cardinalred),
                            ))),
                    ListTile(
                      title: Text(
                        "Configuration",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      onTap: () => Navigator.of(context)
                          .pushReplacement(_createRoute(MainScreen())),
                    ),
                    ListTile(
                      title: Text(
                        "Match Scouting",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      onTap: () => Navigator.of(context)
                          .pushReplacement(_createRoute(const MatchScout())),
                    ),
                    ListTile(
                      title: Text(
                        "Pit Scouting",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      onTap: () => Navigator.of(context)
                          .pushReplacement(_createRoute(const PitScout())),
                    )
                  ],
                )));
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  final GlobalKey<SettingsState> _settingsKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Configuration"),
        ),
        drawer: AppDrawer(),
        body: Settings(key: _settingsKey),
        floatingActionButton: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Cache",
            onPressed: () {
              stock.clearAll();
              tbaStock.clearAll();
              _settingsKey.currentState!.reload();
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
