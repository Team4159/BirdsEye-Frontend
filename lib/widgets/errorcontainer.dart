import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final Object? error;

  const ErrorContainer(this.error, {super.key});

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.red[800],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 5, color: Colors.redAccent)),
      child: Center(
          child: Text(
        error.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
        textAlign: TextAlign.center,
      )));
}
