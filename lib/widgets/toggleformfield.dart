import 'package:birdseye/widgets/formfieldtitle.dart';
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
            builder: (FormFieldState<bool> state) => Material(
                elevation: 2,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                animationDuration: const Duration(milliseconds: 500),
                color: Color(state.value! ? 0xff1C7C7C : 0xffCF772E),
                textStyle: Theme.of(state.context)
                    .textTheme
                    .labelLarge!
                    .copyWith(
                        fontSize: MediaQuery.of(state.context).size.width < 750
                            ? 20
                            : 28),
                child: InkWell(
                    onTap: () {
                      state.didChange(!state.value!);
                    },
                    child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Center(
                              child: Text(Theme.of(state.context).brightness ==
                                      Brightness.light
                                  ? (state.value! ? "Yes" : "No")
                                  : state.value.toString())),
                          FormFieldTitle(labelText),
                        ]))));
}
