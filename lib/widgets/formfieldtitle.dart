import 'package:flutter/material.dart';

class FormFieldTitle extends Builder {
  FormFieldTitle(String title, {super.key})
      : super(
            builder: (context) => Align(
                alignment: Alignment.topCenter,
                child: Baseline(
                    baseline: buttonBaseline,
                    baselineType: TextBaseline.alphabetic,
                    child: FractionallySizedBox(
                        widthFactor: buttonTextWidthFactor,
                        child: FittedBox(
                          alignment: Alignment.topCenter,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )))));
}

const double buttonBaseline = 36;
const double buttonTextWidthFactor = 0.25;
