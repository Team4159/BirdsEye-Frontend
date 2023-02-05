import 'package:flutter/material.dart';

class CounterFormField extends FormField<int> {
  CounterFormField(
      {super.key,
      super.onSaved,
      super.validator,
      super.initialValue = 0,
      super.autovalidateMode = AutovalidateMode.disabled,
      InputDecoration decoration = const InputDecoration()})
      : super(builder: (FormFieldState<int> state) {
          return InputDecorator(
              // TODO: This needs to be customized
              decoration: decoration,
              child: Stack(
                alignment: AlignmentDirectional.center,
                fit: StackFit.passthrough,
                children: [
                  ElevatedButton(
                    child: Text(state.value.toString()),
                    onPressed: () {
                      state.didChange(state.value! + 1);
                    },
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (state.value! <= 0) return;
                          state.didChange(state.value! - 1);
                        },
                      )),
                ],
              ));
        });
}
