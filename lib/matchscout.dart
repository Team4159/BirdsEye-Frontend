// get latest match scouting form -> cache -> ensure app version matches -> process into a form -> user fills form out -> send to server w/ season year, event id, match #

import 'package:flutter/material.dart';

class MatchScout extends StatelessWidget {
  const MatchScout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      child: Column(
        children: const <Widget>[
          Question(question: "How?", answerType: TextInputType.emailAddress),
        ],
      ),
    ));
  }
}

class Question extends StatefulWidget {
  final String question;
  final TextInputType answerType;

  const Question({super.key, required this.question, required this.answerType});

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  String answer = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.question),
        TextFormField(
          keyboardType: widget.answerType,
        ),
        const RadioChoiceFormField(choices: <String>["foo", "bar"]),
        const CheckboxChoiceFormField(choices: <String>["bat", "bazz"])
      ],
    );
  }
}

class RadioChoiceFormField extends StatefulWidget {
  final List<String> choices;

  const RadioChoiceFormField({
    super.key,
    required this.choices,
  });

  @override
  State<RadioChoiceFormField> createState() => _RadioChoiceFormFieldState();
}

class _RadioChoiceFormFieldState extends State<RadioChoiceFormField> {
  int groupValue = -1;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.choices.length,
      itemBuilder: (context, index) {
        return RadioListTile(
            title: Text(widget.choices[index]),
            value: index,
            groupValue: groupValue,
            onChanged: (int? value) {
              if (value == null) {
                return;
              }

              setState(() {
                groupValue = value;
              });
            });
      },
    );
  }
}

class CheckboxChoiceFormField extends StatefulWidget {
  final List<String> choices;

  const CheckboxChoiceFormField({super.key, required this.choices});

  @override
  State<CheckboxChoiceFormField> createState() =>
      _CheckboxChoiceFormFieldState();
}

class _CheckboxChoiceFormFieldState extends State<CheckboxChoiceFormField> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.choices.length,
      itemBuilder: (context, index) {
        return CheckboxListTileWrapper(title: Text(widget.choices[index]));
      },
    );
  }
}

class CheckboxListTileWrapper extends StatefulWidget {
  final Widget title;

  const CheckboxListTileWrapper({Key? key, required this.title})
      : super(key: key);

  @override
  State<CheckboxListTileWrapper> createState() =>
      _CheckboxListTileWrapperState();
}

class _CheckboxListTileWrapperState extends State<CheckboxListTileWrapper> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: widget.title,
      value: isChecked,
      onChanged: (bool? value) {
        if (value == null) {
          return;
        }

        setState(() {
          isChecked = value;
        });
      },
    );
  }
}
