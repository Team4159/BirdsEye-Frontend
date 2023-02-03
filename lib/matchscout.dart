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
        const CheckboxChoiceFormField(choices: <String>["bat", "bazz"]),
        const CounterFormField(),
        const SliderFormField(min: 0, max: 10, divisions: 10),
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

class CounterFormField extends StatefulWidget {
  final int startingNumber;

  const CounterFormField({Key? key, this.startingNumber = 0}) : super(key: key);

  @override
  State<CounterFormField> createState() => _CounterFormFieldState();
}

class _CounterFormFieldState extends State<CounterFormField> {
  late int num;

  @override
  void initState() {
    super.initState();
    num = widget.startingNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (num <= 0) {
              return;
            }

            setState(() {
              num--;
            });
          },
        ),
        TextButton(
          child: Text(num.toString()),
          onPressed: () {
            setState(() {
              num++;
            });
          },
        ),
      ],
    );
  }
}

class SliderFormField extends StatefulWidget {
  final int min;
  final int max;
  final int divisions;

  const SliderFormField(
      {Key? key, required this.min, required this.max, required this.divisions})
      : super(key: key);

  @override
  State<SliderFormField> createState() => _SliderFormFieldState();
}

class _SliderFormFieldState extends State<SliderFormField> {
  late double currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.min.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.min.toString()),
        Slider(
          value: currentValue,
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          label: currentValue.toString(),
          divisions: widget.divisions,
          onChanged: (double? value) {
            if (value == null) {
              return;
            }

            setState(() {
              currentValue = value;
            });
          },
        ),
        Text(widget.max.toString()),
      ],
    );
  }
}
