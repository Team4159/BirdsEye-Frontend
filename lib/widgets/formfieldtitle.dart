import 'package:flutter/material.dart';

class FormFieldTitle extends Builder {
  FormFieldTitle(String title, {super.key})
      : super(
            builder: (context) => Baseline(
                baseline: 36,
                baselineType: TextBaseline.alphabetic,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        widthFactor: buttonTextWidthFactor,
                        heightFactor: 0.4,
                        child: FittedBox(
                          alignment: Alignment.bottomCenter,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Theme.of(context).brightness == Brightness.light
                                ? title.replaceAllMapped(RegExp(r'([A-Z])'),
                                    (Match m) => " ${m.group(0)}")
                                : title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 36),
                          ),
                        )))));
}

const double buttonTextWidthFactor = 0.6;
