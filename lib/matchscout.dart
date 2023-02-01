// get latest match scouting form -> cache -> ensure app version matches -> process into a form -> send to server
import 'package:flutter/material.dart';

class MatchScout extends StatelessWidget {
  const MatchScout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class Question extends StatelessWidget {
  final String question;
  final AnswerType answerType;

  const Question({
    required super.key,
    required this.question,
    required this.answerType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(),
    );
  }
}

enum AnswerType {
  number,
  string,
  date,
}
