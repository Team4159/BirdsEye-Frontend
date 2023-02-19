import 'package:birdseye/widgets/formfieldtitle.dart';
import 'package:flutter/material.dart';

class CounterFormField extends FormField<int> {
  CounterFormField(
      {super.key,
      super.onSaved,
      super.validator,
      super.initialValue = 0,
      super.autovalidateMode = AutovalidateMode.disabled,
      String labelText = ""})
      : super(
            builder: (FormFieldState<int> state) => Stack(
                  alignment: AlignmentDirectional.center,
                  fit: StackFit.passthrough,
                  children: [
                    ElevatedButton(
                      child: Center(
                          child: Text(
                        state.value.toString(),
                        style: const TextStyle(fontSize: 28),
                      )),
                      onPressed: () {
                        state.didChange(state.value! + 1);
                      },
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(Icons.remove),
                          iconSize: 32,
                          color: Colors.white70,
                          onPressed: () {
                            if (state.value! <= 0) return;
                            state.didChange(state.value! - 1);
                          },
                        )),
                    FormFieldTitle(labelText),
                  ],
                ));
}
