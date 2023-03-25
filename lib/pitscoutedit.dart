import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:flutter/material.dart';

class PitScoutEdit extends StatefulWidget {
  final Map<String, dynamic> pitResponse;

  const PitScoutEdit({super.key, required this.pitResponse});

  @override
  State<PitScoutEdit> createState() => _PitScoutEditState();
}

class _PitScoutEditState extends State<PitScoutEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _fields = {};

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Pit Scouting"),
      ),
      drawer: AppDrawer(),
      body: Form(key: _formKey, child: Text("E")));

  // To satisfy dart use_build_context_synchronously in async functions
  void showSnackBar(SnackBar snackbar) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
