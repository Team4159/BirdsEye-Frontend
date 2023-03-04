import 'package:birdseye/widgets/formfieldtitle.dart';
import 'package:flutter/material.dart';

class SliderFormField extends FormField<double> {
  static final List<String> labels = ["poor", "okay", "avg", "good", "nice"];

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
                        label: labels[state.value!.toInt()],
                        value: state.value ?? initialValue!,
                        onChanged: (double value) {
                          state.didChange(value);
                        },
                        min: 1,
                        max: 5,
                        divisions: 4,
                      ),
                      FormFieldTitle(labelText),
                    ]));
}
