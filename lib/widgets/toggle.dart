import 'package:flutter/material.dart';

class ToggleFormField extends FormField<bool> {
  ToggleFormField(
      {super.key,
      super.onSaved,
      super.validator,
      super.initialValue = false,
      super.autovalidateMode = AutovalidateMode.disabled,
      String labelText = ""})
      : super(
            builder: (FormFieldState<bool> state) => ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) =>
                        state.value! ? Colors.blue : Colors.orange)),
                onPressed: () {
                  state.didChange(!state.value!);
                },
                child: Center(
                    child: Text(
                  labelText,
                  style: TextStyle(
                      fontFamily: "verdana",
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: state.value! ? Colors.white : Colors.black),
                ))));
}
