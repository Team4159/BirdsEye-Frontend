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
                onPressed: () {
                  state.didChange(!state.value!);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) =>
                        Color(state.value! ? 0xff1C7C7C : 0xffCF772E))),
                child: Center(
                    child: Text(labelText,
                        style: Theme.of(state.context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: state.value!
                                    ? Colors.white
                                    : Colors.black)))));
}
