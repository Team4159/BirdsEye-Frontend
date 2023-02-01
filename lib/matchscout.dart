// get latest match scouting form -> cache -> ensure app version matches -> process into a form -> user fills form out -> send to server w/ season year, event id, match #
import 'package:flutter/material.dart';

class MatchScout extends StatelessWidget {
  const MatchScout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: const [
        Question(question: "What is your name?", answerType: AnswerType.string)
      ],
    ));
  }
}

class Question extends StatefulWidget {
  final String question;
  final AnswerType answerType;

  const Question({Key? key, required this.question, required this.answerType})
      : super(key: key);

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  String answer = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.question),
        ],
      ),
    );
  }
}

enum AnswerType {
  number,
  string,
  date,
}
