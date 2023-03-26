import 'package:birdseye/widgets/formfieldtitle.dart';
import 'package:flutter/material.dart';

class RatingFormField extends FormField<int> {
  static final List<String> labels = ["poor", "bad", "okay", "good", "pro"];

  RatingFormField(
      {super.key, super.onSaved, super.initialValue = 3, String labelText = ""})
      : super(
            builder: (FormFieldState<int> state) => Material(
                type: MaterialType.card,
                elevation: 2,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                animationDuration: const Duration(milliseconds: 500),
                textStyle: Theme.of(state.context).textTheme.labelLarge,
                child: Stack(
                    alignment: AlignmentDirectional.center,
                    fit: StackFit.passthrough,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                            5,
                            (index) => IconButton(
                                onPressed: () {
                                  state.didChange(index + 1);
                                },
                                iconSize: 30,
                                tooltip: labels[index],
                                icon: index + 1 <= (state.value ?? -1)
                                    ? const Icon(Icons.star_rounded,
                                        color: Colors.yellow)
                                    : const Icon(Icons.star_border_rounded,
                                        color: Colors.grey))),
                      ),
                      FormFieldTitle(labelText),
                    ])));
}
