import 'package:flutter/material.dart';

import '../main.dart';

class SliderFormField extends FormField<double> {
  SliderFormField(
      {super.key,
      super.onSaved,
      super.validator,
      super.initialValue = 3,
      String labelText = ""})
      : super(
            builder: (FormFieldState<double> state) => Stack(
                    alignment: AlignmentDirectional.center,
                    fit: StackFit.passthrough,
                    children: [
                      Slider(
                        label: state.value!.toInt().toString(),
                        value: state.value ?? initialValue!,
                        onChanged: (double value) {
                          state.didChange(value);
                        },
                        min: 1,
                        max: 5,
                        divisions: 4,
                      ),
                      Align(
                          alignment: Alignment.topCenter,
                          child: Baseline(
                            baseline: buttonBaseline,
                            baselineType: TextBaseline.alphabetic,
                            child: Text(
                              labelText,
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(state.context).textTheme.bodyMedium,
                            ),
                          )),
                    ]));
}
