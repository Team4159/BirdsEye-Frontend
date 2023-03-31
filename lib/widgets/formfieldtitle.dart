import 'package:flutter/material.dart';

class FormFieldTitle extends StatelessWidget {
  final String title;
  const FormFieldTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
          alignment: Alignment.bottomCenter,
          widthFactor: 0.9,
          heightFactor: 0.4,
          child: FittedBox(
            alignment: Alignment.bottomCenter,
            fit: BoxFit.scaleDown,
            child: Text(
              Theme.of(context).brightness == Brightness.light
                  ? title.replaceAllMapped(
                      RegExp(r'([A-Z])'), (Match m) => " ${m.group(0)}")
                  : title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          )));
}
