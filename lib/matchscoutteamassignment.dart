import 'package:birdseye/main.dart';
import 'package:flutter/material.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScoutTeamAssignment extends StatefulWidget {
  const MatchScoutTeamAssignment({super.key});

  @override
  State<StatefulWidget> createState() => MatchScoutTeamAssignmentState();
}

class MatchScoutTeamAssignmentState extends State<MatchScoutTeamAssignment> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, Map<String, dynamic>> _fields = {};
  bool _loading = false;
  List<String>? _matches;

  @override
  void initState() {
    super.initState();
    // make call to backend to get current matches
    // assign result to _matches
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Match Scouting"),
        ),
        drawer: AppDrawer(),
        body: Center(
          child: Column(children: [
            Row(
              children: _matches != null
                  ? matches()
                  :
                  // [
                  //   TextButton(
                  //       onPressed: (() {
                  //         print("did press");
                  //       }),
                  //       child: const Text("Start")),
                  //       TextButton(
                  //       onPressed: (() {
                  //         print("did press");
                  //       }),
                  //       child: const Text("Start"))
                  // ]
                  [const Center(child: CircularProgressIndicator())],
              // [
              //   TextButton(
              //       onPressed: (() {
              //         print("did press");
              //       }),
              //       child: const Text("Start"))
              // ],
            )
          ]),
        ),
      );

  List<Widget> matches() {
    return _matches!
        .map((e) => TextButton(
            onPressed: (() {
              print("did press");
            }),
            child: const Text("Start")))
        .toList();
  }
}
