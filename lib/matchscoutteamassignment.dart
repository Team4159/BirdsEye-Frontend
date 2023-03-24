import 'package:birdseye/main.dart';
import 'package:birdseye/matchscout.dart';
import 'package:flutter/material.dart';
import 'package:birdseye/web.dart';

enum MatchScoutQuestionTypes { text, counter, toggle, slider }

class MatchScoutTeamAssignment extends StatefulWidget {
  const MatchScoutTeamAssignment({super.key});

  @override
  State<StatefulWidget> createState() => MatchScoutTeamAssignmentState();
}

class MatchModel {
  String name;
  List<TeamAssignment> teams;

  MatchModel(this.name, this.teams);
}

class TeamAssignment {
  int teamNumber = 0;
  bool isAssigned = false;

  TeamAssignment(this.teamNumber, this.isAssigned);
}

class MatchScoutTeamAssignmentState extends State<MatchScoutTeamAssignment> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, Map<String, dynamic>> _fields = {};
  bool _loading = false;
  List<MatchModel>? _matches;

  @override
  void initState() {
    super.initState();
    // make call to backend to get current matches
    // assign result to _matches

    _matches = [
      MatchModel("qa15", [
        TeamAssignment(4159, true),
        TeamAssignment(254, false),
        TeamAssignment(604, true),
      ]),
      MatchModel("qa16", [
        TeamAssignment(4159, false),
        TeamAssignment(254, true),
        TeamAssignment(604, true),
      ]),
    ];
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
                  : [const Center(child: CircularProgressIndicator())],
            )
          ]),
        ),
      );

  List<Widget> matches() {
    return _matches!
        .map((match) => Column(children: [
              Text(match.name),
              Column(children: teamsList(match)),
              TextButton(
                  onPressed: (() {
                    print("did press");
                    getScoutingAssignment(match.name)
                        .then((value) => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MatchScout(
                                          teamNumber: value.teamNumber,
                                          matchId: match.name,
                                        )),
                              )
                            })
                        .catchError((error) {
                      print("error $error");
                    });
                    // Make reqeust to server requesting a team assignment
                    // Move to next screen on success passing through match
                    // and team information.
                  }),
                  child: const Text("Start")),
            ]))
        .toList();
  }

  List<Widget> teamsList(MatchModel match) {
    return match.teams.map((team) {
      return Text("${team.teamNumber}",
          style: team.isAssigned
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null);
    }).toList();
  }
}

class ScoutingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scoutin'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoutingCard('First Scouting List'),
            SizedBox(width: 16),
            _buildScoutingCard('Second Scouting List'),
          ],
        ),
      ),
    );
  }

  Widget _buildScoutingCard(String title) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // replace with actual item count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // handle button press
            },
            child: Text('Start Scouting'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
