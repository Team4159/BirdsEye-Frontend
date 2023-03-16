import 'dart:convert';

import 'package:birdseye/settings.dart';
import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class AdminPanel extends StatelessWidget {
  final TextEditingController _yearController =
      TextEditingController(text: "2023");

  AdminPanel({super.key});

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
          decoration: const InputDecoration(counterText: "", labelText: "Year"),
        ),
        const TextField(
          maxLength: 4,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(counterText: "", labelText: "Event Code"),
        ),
        TextButton(onPressed: () {}, child: const Text("Get Event List")),
        FutureBuilder(
            future: getEventList(int.parse(_yearController.text)),
            builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              Response? res =
                  snapshot.inState(ConnectionState.done).data as Response?;

              return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int i) {
                    if (res == null || jsonDecode(res.body).length <= i) {
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
}
