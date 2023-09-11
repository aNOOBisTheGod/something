// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class WrongPhonesScreen extends StatefulWidget {
  const WrongPhonesScreen({super.key});

  @override
  State<WrongPhonesScreen> createState() => _WrongPhonesScreenState();
}

class _WrongPhonesScreenState extends State<WrongPhonesScreen> {
  int _bodyIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _bodyIndex,
          onTap: (i) => setState(() => _bodyIndex = i),
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: const Icon(Icons.watch),
              title: const Text("Home"),
              selectedColor: Colors.purple,
            ),

            /// Likes
            SalomonBottomBarItem(
              icon: const Icon(Icons.history),
              title: const Text("History"),
              selectedColor: Colors.pink,
            ),
          ],
        ),
        body: _bodyIndex == 0 ? const StopwatchPage() : const HistoryPage());
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool started = false;

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start training!'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.5),
      ),
      body: StreamBuilder<int>(
        stream: _stopWatchTimer.rawTime,
        initialData: 0,
        builder: (context, snap) {
          final value = snap.data;
          final displayTime = StopWatchTimer.getDisplayTime(value!);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    displayTime,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .apply(fontSizeDelta: 20),
                  ),
                ),
                !started
                    ? ElevatedButton(
                        onPressed: () {
                          _stopWatchTimer.onStartTimer();
                          setState(() {
                            started = !started;
                          });
                        },
                        child: const Text("Start stopwatch"))
                    : ElevatedButton(
                        onPressed: () {
                          _stopWatchTimer.onStopTimer();
                          setState(() {
                            started = !started;
                          });
                        },
                        child: const Text("Pause stopwatch")),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      _stopWatchTimer.onResetTimer();
                    },
                    child: const Text("Reset stopwatch")),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                TextEditingController titleController = TextEditingController();
                TextEditingController descriptionController =
                    TextEditingController();
                return Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: titleController,
                          maxLength: 20,
                          decoration: const InputDecoration(
                            hintText: "Insert title",
                          ),
                        ),
                        TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: descriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 8,
                          decoration: const InputDecoration(
                              hintText: "Insert description"),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              _stopWatchTimer.onStopTimer();
                              SharedPreferences instance =
                                  await SharedPreferences.getInstance();
                              List history = json.decode(
                                  instance.getString('history') ?? '[]');
                              history.add({
                                'id': Random().nextInt(10000000),
                                'title': titleController.text,
                                'description': descriptionController.text,
                                'date': DateFormat('dd-MM-yyyy – kk:mm')
                                    .format(DateTime.now()),
                                'time': StopWatchTimer.getDisplayTime(
                                    _stopWatchTimer.rawTime.value)
                              });
                              instance.setString(
                                  'history', json.encode(history));
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Attention"),
                                        content: const Text("Training added!"),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Ok"))
                                        ],
                                      ));
                            },
                            child: const Text("Save"))
                      ],
                    ),
                  ),
                );
              });
        },
        tooltip: "Save training",
        child: const Icon(Icons.save),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryWidget> historyWidgets = [];

  Future<void> fetchHistory() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    List history = json.decode(instance.getString('history') ?? '[]');
    historyWidgets = [];
    for (var element in history) {
      historyWidgets.add(
        HistoryWidget(
          id: element['id'],
          title: element['title'],
          description: element['description'],
          date: element['date'],
          time: element['time'],
          onEdit: editNote,
          onDelete: deleteNote,
        ),
      );
    }
    setState(() {});
  }

  Future<void> deleteNote(int noteId) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    List history = json.decode(instance.getString('history') ?? '[]');
    history.removeWhere((element) => element['id'] == noteId);
    instance.setString('history', json.encode(history));
    fetchHistory();
  }

  Future<void> editNote(int noteId, String title, String description) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    List history = json.decode(instance.getString('history') ?? '[]');
    int index = history.indexWhere((element) => element['id'] == noteId);
    history[index]['title'] = title;
    history[index]['description'] = description;
    instance.setString('history', json.encode(history));
    fetchHistory();
  }

  @override
  void initState() {
    fetchHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your diary'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.5),
      ),
      body: historyWidgets.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: historyWidgets,
              ),
            )
          : const Center(
              child: Text("Wow! So empty here!"),
            ),
    );
  }
}

class HistoryWidget extends StatelessWidget {
  int id;
  String title;
  String description;
  String date;
  String time;
  Function(int) onDelete;
  Function(int, String, String) onEdit;
  HistoryWidget(
      {super.key,
      required this.id,
      required this.title,
      required this.description,
      required this.date,
      required this.time,
      required this.onDelete,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    description,
                  ),
                  Text(
                    date,
                  ),
                ],
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * .5 - 32,
                child:
                    Text(time, style: Theme.of(context).textTheme.bodyLarge)),
          ]),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController titleController =
                            TextEditingController(text: title);
                        TextEditingController descriptionController =
                            TextEditingController(text: description);
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: titleController,
                                  maxLength: 20,
                                  decoration: const InputDecoration(
                                    hintText: "Insert title",
                                  ),
                                ),
                                TextField(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  controller: descriptionController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 8,
                                  decoration: const InputDecoration(
                                      hintText: "Insert description"),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      onEdit(id, titleController.text,
                                          descriptionController.text);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Save"))
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: const Text("Edit training"),
              ),
              Divider(
                indent: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text("Attention"),
                            content: const Text(
                                "Do you really want to delete this training?"),
                            actions: [
                              ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("No")),
                              ElevatedButton(
                                  onPressed: () {
                                    onDelete(id);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Yes"))
                            ],
                          ));
                },
                child: const Text("Delete training"),
              )
            ],
          ),
        ),
        Container(
          height: 1,
          color: Colors.grey.withOpacity(.5),
          width: MediaQuery.of(context).size.width * .8,
        ),
      ],
    );
  }
}
