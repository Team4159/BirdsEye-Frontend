import 'package:flutter/material.dart';

import 'formfieldtitle.dart';

class ToggleFormField extends FormField<bool> {
  ToggleFormField(
      {super.key,
      super.onSaved,
      super.validator,
      super.initialValue = false,
      super.autovalidateMode = AutovalidateMode.disabled,
      String labelText = ""})
      : super(
            builder: (FormFieldState<bool> state) => Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            state.didChange(!state.value!);
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Color(
                                      state.value! ? 0xff1C7C7C : 0xffCF772E))),
                          child: Center(
                              child: Text(
                            state.value.toString(),
                            style: const TextStyle(fontSize: 28),
                          ))),
                      FormFieldTitle(labelText),
                    ]));
}
