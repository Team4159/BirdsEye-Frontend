import 'package:birdseye/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int? _season;
  List<String>? tableList;

  refreshTables() {
    tableList = [];
    getTableList(_season!).then((value) => setState(() => tableList = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                        width: 100,
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                              labelText: "Season", counterText: ""),
                          maxLength: 4,
                          onSubmitted: (value) {
                            _season = int.parse(value);
                            refreshTables();
                          },
                        ))),
                ElevatedButton(
                    onPressed: () => _season == null
                        ? null
                        : showDialog(
                            context: context,
                            builder: (lctx) => ConfigDialog(
                                  getSeason: () => _season!,
                                  onFinished: () => refreshTables(),
                                )),
                    child: const Text("Create Event")),
                tableList == null
                    ? const SizedBox(height: 0)
                    : ListView(
                        shrinkWrap: true,
                        children: tableList!
                            .map((tableName) => Text(tableName))
                            .toList(),
                      )
              ],
            )));
  }
}

class ConfigDialog extends StatefulWidget {
  final int Function() getSeason;
  final VoidCallback? onFinished;
  const ConfigDialog({super.key, required this.getSeason, this.onFinished});

  @override
  State<StatefulWidget> createState() => ConfigDialogState();
}

class ConfigDialogState extends State<ConfigDialog> {
  String? _eventCode;
  String? _eventError;
  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: const Text("Event Config"),
        contentPadding: const EdgeInsets.all(10),
        children: [
          SizedBox(
              width: 100,
              child: Autocomplete(
                  optionsBuilder: (textEditingValue) => tbaStock
                      .get(widget.getSeason().toString())
                      .then((value) => value.keys.where((element) =>
                          element.startsWith(textEditingValue.text))),
                  fieldViewBuilder: (context, textEditingController, focusNode,
                          onFieldSubmitted) =>
                      TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                            labelText: "Event Code", errorText: _eventError),
                        onSubmitted: (value) {
                          onFieldSubmitted();
                          setState(() => _eventError = "Loading");
                          tbaStock
                              .get(widget.getSeason().toString())
                              .then((events) {
                            if (events.containsKey(value)) {
                              _eventCode = value;
                              setState(() => _eventError = null);
                            } else {
                              _eventCode = null;
                              setState(() => _eventError = "Invalid");
                            }
                          });
                        },
                      ),
                  onSelected: (value) => _eventCode = value)),
          TextButton(
              onPressed: () {
                if (_eventCode == null) return;
                createTables(widget.getSeason(), _eventCode!).then((value) {
                  if (widget.onFinished != null) {
                    widget.onFinished!();
                  }
                  Navigator.of(context).pop();
                });
              },
              child: const Text("Submit"))
        ],
      );
}
