import 'package:flutter/material.dart';

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
                    borderSide: BorderSide(color: Colors.grey[700]!)),
                labelText: labelText));
}
