import 'dart:math' show min;

import 'package:birdseye/settings.dart';
import 'package:birdseye/widgets/formfieldtitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterFormField extends FormField<int> {
  CounterFormField(
      {super.key, super.onSaved, super.initialValue = 0, String? labelText})
      : super(
            builder: (FormFieldState<int> state) => Material(
                elevation: 2,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                animationDuration: const Duration(milliseconds: 500),
                color: getColor(state.context, labelText) ??
                    Theme.of(state.context).colorScheme.primary,
                textStyle: Theme.of(state.context).textTheme.labelLarge,
                child: InkWell(
                    onTap: () {
                      state.didChange(state.value! + 1);
                      HapticFeedback.lightImpact();
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      fit: StackFit.passthrough,
                      children: [
                        Center(
                            child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  state.value.toString(),
                                  textScaleFactor:
                                      MediaQuery.of(state.context).size.width <
                                              750
                                          ? 1.7
                                          : 2,
                                ))),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.remove),
                              iconSize: min(
                                  MediaQuery.of(state.context).size.width / 18,
                                  40),
                              color: Colors.white70,
                              padding: const EdgeInsets.only(right: 5),
                              onPressed: () {
                                if (state.value! <= 0) return;
                                state.didChange(state.value! - 1);
                              },
                            )),
                        if (labelText != null) FormFieldTitle(labelText),
                      ],
                    ))));
  static Color? getColor(BuildContext context, String? labelText) {
    if (labelText == null) return null;
    // FIXME: Season-Specific
    return SettingsState.season != 2023
        ? null
        : labelText.toLowerCase().startsWith("cone")
            ? const Color(0xffccc000)
            : labelText.toLowerCase().startsWith("cube")
                ? const Color(0xffa000a0)
                : null;
  }
}

class ToggleFormField extends FormField<bool> {
  ToggleFormField(
      {super.key,
      super.onSaved,
      super.initialValue = false,
      String labelText = ""})
      : super(
            builder: (FormFieldState<bool> state) => Material(
                elevation: 2,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                animationDuration: const Duration(milliseconds: 500),
                color: state.value!
                    ? Theme.of(state.context).colorScheme.secondaryContainer
                    : Theme.of(state.context).colorScheme.tertiaryContainer,
                textStyle: Theme.of(state.context).textTheme.labelLarge,
                child: InkWell(
                    onTap: () {
                      state.didChange(!state.value!);
                      HapticFeedback.lightImpact();
                    },
                    child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Center(
                              child: Text(
                            Theme.of(state.context).brightness ==
                                    Brightness.light
                                ? (state.value! ? "Yes" : "No")
                                : state.value.toString(),
                            textScaleFactor:
                                MediaQuery.of(state.context).size.width < 750
                                    ? 1.7
                                    : 2,
                          )),
                          FormFieldTitle(labelText),
                        ]))));
}

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
                      FittedBox(
                          alignment: Alignment.center,
                          fit: BoxFit.scaleDown,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: List.generate(
                                    5,
                                    (index) => IconButton(
                                        onPressed: () {
                                          state.didChange(index + 1);
                                          HapticFeedback.lightImpact();
                                        },
                                        iconSize: 30,
                                        tooltip: labels[index],
                                        icon: index + 1 <= (state.value ?? -1)
                                            ? const Icon(Icons.star_rounded,
                                                color: Colors.yellow)
                                            : const Icon(
                                                Icons.star_border_rounded,
                                                color: Colors.grey))),
                              ))),
                      FormFieldTitle(labelText),
                    ])));
}

class STextFormField extends TextFormField {
  STextFormField(
      {super.key, super.onSaved, super.initialValue, String labelText = ""})
      : super(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                    bottom: 4, top: 10, left: 10, right: 10),
                counterText: null,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!, width: 4)),
                labelText: labelText));
}
