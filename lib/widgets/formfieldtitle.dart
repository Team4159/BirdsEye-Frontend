import 'package:flutter/material.dart';

class FormFieldTitle extends Builder {
  FormFieldTitle(String title, {super.key})
      : super(
            builder: (context) => Align(
                alignment: Alignment.topCenter,
                child: Baseline(
                    baseline: MediaQuery.of(context).size.width < 750 ? 24 : 36,
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

const double buttonTextWidthFactor = 0.6;
