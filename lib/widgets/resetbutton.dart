import 'package:flutter/material.dart';

class ResetButton extends StatefulWidget {
  final Function() reset;

  const ResetButton({super.key, required this.reset});

  @override
  State<ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<ResetButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      constraints: const BoxConstraints(minWidth: 40),
      child: IconButton(
        focusNode: FocusNode(skipTraversal: true),
        icon: Icon(Icons.delete, color: Colors.red[800]),
        tooltip: "Reset",
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm Reset"),
                  content: const Text("Are you sure you want to reset?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.reset();
                        },
                        child: const Text("Reset"))
                  ],
                );
              });
        },
      ),
    );
  }
}
