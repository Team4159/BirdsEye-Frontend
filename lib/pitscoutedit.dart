import 'package:birdseye/main.dart';
import 'package:birdseye/web.dart';
import 'package:birdseye/widgets/errorcontainer.dart';
import 'package:flutter/material.dart';

class PitScoutEdit extends StatefulWidget {
  final Map<String, dynamic> pitQuestions;
  final Map<String, dynamic> pitResponse;

  const PitScoutEdit(
      {super.key, required this.pitQuestions, required this.pitResponse});

  @override
  State<PitScoutEdit> createState() => _PitScoutEditState();
}

class _PitScoutEditState extends State<PitScoutEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _fields = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pit Scout Response"),
      ),
      drawer: AppDrawer(),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              controller: _scrollController,
              child: Column(
                children: widget.pitResponse.entries
                    .map<Widget>((e) => Material(
                          type: MaterialType.card,
                          elevation: 1,
                          child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.key,
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                      textScaleFactor: 1.2,
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 8),
                                          filled: true,
                                          counterText: null,
                                          border: const OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey[700]!))),
                                      onSaved: (String? content) {
                                        _fields[e.key] = content ?? "";
                                      },
                                    )
                                  ])),
                        ))
                    .followedBy([
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ButtonStyle(enableFeedback: !_loading),
                              onPressed: () {},
                              child: const Text("Submit")))
                    ])
                    .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        child: e))
                    .toList(),
              ))));

  // To satisfy dart use_build_context_synchronously in async functions
  void showSnackBar(SnackBar snackbar) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
