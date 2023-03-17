import 'dart:convert';

import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
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
          decoration: const InputDecoration(labelText: "Event Code (Optional)"),
        ),
        MenuItemButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text("Get Event List")),
        MenuItemButton(
            onPressed: () async {
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
        FutureBuilder(
            future: getEventList(int.parse(_yearController.text)),
            builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              Response? res =
                  snapshot.inState(ConnectionState.done).data as Response?;

              return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int i) {
                    if (res == null || jsonDecode(res.body).length <= i) {
                      if (i == 0) {
                        showSnackBar(const Text("No events"));
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
