import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // カレンダー用のパッケージ

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar with Events'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _showEventDialog();
              });
            },
          ),
          Expanded(
            child: ListView(
              children: _buildEventList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDialog() {
    final TextEditingController _eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: TextField(
            controller: _eventController,
            decoration: InputDecoration(hintText: 'Enter event description'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_eventController.text.isNotEmpty) {
                  setState(() {
                    if (_events[_selectedDay] == null) {
                      _events[_selectedDay] = [];
                    }
                    _events[_selectedDay]!.add(_eventController.text);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildEventList() {
    // 選択された日のイベントリストを取得
    final events = _events[_selectedDay] ?? [];
    // イベントがない場合はメッセージを表示
    if (events.isEmpty) {
      return [ListTile(title: Text('No events for this day'))];
    }
    // イベントリストをListTileに変換
    return List.generate(events.length, (index) {
      final event = events[index];
      return ListTile(
        title: Text(event),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _showDeleteConfirmationDialog(index);
          },
        ),
      );
    });
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _events[_selectedDay]!.removeAt(index);
                  if (_events[_selectedDay]!.isEmpty) {
                    _events.remove(_selectedDay);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
