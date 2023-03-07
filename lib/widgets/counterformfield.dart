import 'dart:math' show min;

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
            builder: (FormFieldState<int> state) => Material(
                elevation: 2,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                animationDuration: const Duration(milliseconds: 500),
                color: Theme.of(state.context).colorScheme.primary,
                textStyle: Theme.of(state.context)
                    .textTheme
                    .labelLarge!
                    .copyWith(
                        fontSize: MediaQuery.of(state.context).size.width < 750
                            ? 20
                            : 28),
                child: InkWell(
                    onTap: () {
                      state.didChange(state.value! + 1);
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      fit: StackFit.passthrough,
                      children: [
                        Center(child: Text(state.value.toString())),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.remove),
                              iconSize: min(
                                  MediaQuery.of(state.context).size.width / 18,
                                  40),
                              color: Colors.white70,
                              onPressed: () {
                                if (state.value! <= 0) return;
                                state.didChange(state.value! - 1);
                              },
                            )),
                        FormFieldTitle(labelText),
                      ],
                    ))));
}
