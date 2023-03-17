import 'dart:convert';

import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _yearController =
      TextEditingController(text: "2023");
  final TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        TextField(
          controller: _yearController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 4,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: "Year"),
        ),
        TextField(
          controller: _eventController,
          maxLength: 4,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: "Event Code"),
        ),
        MenuItemButton(
            onPressed: () {
              if (_yearController.text.isEmpty) {
                return showSnackBar(const Text("Missing required fields"));
              }

              setState(() {});
            },
            child: const Text("Get Event List")),
        MenuItemButton(
            onPressed: () async {
              if (_yearController.text.isEmpty ||
                  _eventController.text.isEmpty) {
                return showSnackBar(const Text("Missing required fields"));
              }

              Response res = await createEvent(
                  _yearController.text, _eventController.text);

              if (res.statusCode == 200) {
                showSnackBar(const Text("Success!"));
              } else {
                return showSnackBar(
                    Text("ERROR ${res.statusCode}: ${res.reasonPhrase}"));
              }

              setState(() {});
            },
            child: const Text("Add Event")),
        Text("Events", style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
            future: getEventList(int.parse(_yearController.text)),
            builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return ListView(
                  shrinkWrap: true,
                );
              }

              Response res =
                  snapshot.inState(ConnectionState.done).data as Response;

              return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int i) {
                    if (jsonDecode(res.body).length <= i) {
                      if (i == 0) {
                        SchedulerBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          showSnackBar(const Text("No events"));
                        });
                      }

                      return null;
                    }

                    return ListTile(
                      title: Text(jsonDecode(res.body)[i]),
                    );
                  });
            }),
      ]),
    );
  }

  void showSnackBar(Widget content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: content));
  }
}