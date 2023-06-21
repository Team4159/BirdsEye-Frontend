import 'package:birdseye/matchscout.dart';
import 'package:birdseye/pitscout.dart';
import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    if ({
      AuthChangeEvent.mfaChallengeVerified,
      AuthChangeEvent.passwordRecovery,
      AuthChangeEvent.tokenRefreshed
    }.contains(event.event)) return;
    UserDetails.update();
  });
  if (!UserDetails.isAuthenticated) {
    await Supabase.instance.client.auth.signInWithOAuth(Provider.github,
        authScreenLaunchMode: LaunchMode.externalNonBrowserApplication);
  } else {
    UserDetails.update();
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
      darkTheme: ThemeData.localize(
          ThemeData.dark(useMaterial3: true).copyWith(
              // TODO: Improve dark theme typography
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.red[800]!,
                  secondaryContainer: const Color(0xff1C7C7C),
                  tertiaryContainer: const Color(0xffCF772E),
                  surface: cardinalred),
              appBarTheme: const AppBarTheme(
                  titleTextStyle: TextStyle(
                      fontFamily: "Verdana",
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 28),
                  centerTitle: false),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                  linearTrackColor: Colors.transparent,
                  refreshBackgroundColor: Colors.transparent)),
          Typography.whiteHelsinki.merge(Typography.englishLike2021).apply(bodyColor: Colors.white, displayColor: Colors.grey[300], fontFamilyFallback: ["Arial", "Calibri"]).copyWith(
              titleLarge: const TextStyle(fontFamily: "Verdana"),
              displaySmall: const TextStyle(fontFamily: "OpenSans"),
              displayMedium: const TextStyle(
                  fontFamily: "VarelaRound", letterSpacing: 2, fontSize: 48))),
      theme: ThemeData.localize(
          ThemeData.light(useMaterial3: true).copyWith(
              appBarTheme: const AppBarTheme(
                  backgroundColor: cardinalred,
                  titleTextStyle: TextStyle(
                      fontFamily: "Verdana",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 28),
                  centerTitle: true),
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.red[600]!,
                  secondaryContainer: const Color(0xff1C7C7C),
                  tertiaryContainer: const Color(0xffCF772E),
                  surface: cardinalred)),
          Typography.blackCupertino
              .merge(Typography.englishLike2021)
              .apply(bodyColor: Colors.black, displayColor: Colors.white, fontFamilyFallback: ["Arial", "Calibri"]).copyWith(titleLarge: const TextStyle(fontFamily: "Verdana"), displaySmall: const TextStyle(fontFamily: "OpenSans"), displayMedium: const TextStyle(fontFamily: "VarelaRound", letterSpacing: 2, fontSize: 48)))));
}

late SharedPreferences prefs;

class AppDrawer extends Builder {
  AppDrawer({super.key})
      : super(
            builder: (context) => Drawer(
                width: 200,
                child: Column(children: [
                  const SizedBox(
                      height: 60,
                      child: DrawerHeader(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Bird's Eye",
                            style:
                                TextStyle(fontFamily: "HemiHead", fontSize: 32),
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
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: GestureDetector(
                              onLongPress: () => !UserDetails.isAuthenticated
                                  ? null
                                  : showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        GlobalKey<FormState> formKey =
                                            GlobalKey();
                                        String name = UserDetails.name;
                                        int team = UserDetails.team;
                                        return FractionallySizedBox(
                                            heightFactor: 0.6,
                                            child: Dialog(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Form(
                                                        key: formKey,
                                                        child: Column(
                                                            children: [
                                                              Text(
                                                                  "Modify User Info",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .titleLarge),
                                                              TextFormField(
                                                                initialValue:
                                                                    name,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        labelText:
                                                                            "Name"),
                                                                onSaved: (String?
                                                                        value) =>
                                                                    name = value ??
                                                                        "User",
                                                              ),
                                                              TextFormField(
                                                                initialValue: team
                                                                    .toString(),
                                                                decoration: const InputDecoration(
                                                                    labelText:
                                                                        "Team",
                                                                    counterText:
                                                                        ""),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                maxLength: 4,
                                                                onSaved: (String?
                                                                        value) =>
                                                                    team = int.parse(
                                                                        value ??
                                                                            "0"),
                                                              ),
                                                              TextFormField(
                                                                initialValue: prefs
                                                                    .getString(
                                                                        "tbaKey"),
                                                                decoration: const InputDecoration(
                                                                    labelText:
                                                                        "TBA API Key",
                                                                    counterText:
                                                                        ""),
                                                                maxLength: 65,
                                                                validator: (value) =>
                                                                    (value?.length ??
                                                                                0) !=
                                                                            65
                                                                        ? "Wrong Length"
                                                                        : null,
                                                                onSaved: (String?
                                                                        value) =>
                                                                    prefs.setString(
                                                                        "tbaKey",
                                                                        value ??
                                                                            ""),
                                                              ),
                                                              Expanded(
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomCenter,
                                                                      child: ElevatedButton(
                                                                          onPressed: () {
                                                                            formKey.currentState!.save();
                                                                            Supabase
                                                                                .instance.client
                                                                                .from(
                                                                                    "users")
                                                                                .update(<String, dynamic>{
                                                                                  "name": name,
                                                                                  "team": team
                                                                                })
                                                                                .eq("id", UserDetails.id)
                                                                                .then((_) {
                                                                                  Navigator.of(context).pop();
                                                                                  UserDetails.update();
                                                                                })
                                                                                .catchError((e) {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                                                                }); // FIXME doesnt update
                                                                          },
                                                                          child: const Text("Submit"))))
                                                            ])))));
                                      }),
                              child: UserAccountsDrawerHeader(
                                  margin:
                                      const EdgeInsets.only(top: 15, bottom: 0),
                                  decoration:
                                      const BoxDecoration(color: cardinalred),
                                  currentAccountPicture: Icon(
                                      UserDetails.isAuthenticated
                                          ? Icons.person
                                          : Icons.person_off_outlined,
                                      size: 64),
                                  accountName: Text(UserDetails.name),
                                  accountEmail:
                                      Text("Team ${UserDetails.team}")))))
                ])));
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
