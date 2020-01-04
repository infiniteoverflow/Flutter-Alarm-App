import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';


void main() async {
  runApp(MyApp());
  await AndroidAlarmManager.initialize();

  print("AndroidAlarmManager initialized!");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Alarm App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool switch_value = false;

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;

  DateTime _dateTime = DateTime.now();
  Timer _timer;

  var alarmId = 0;

  bool play = true;
  int flag = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
//       _timer = Timer(
//         Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
//         _updateTime,
//       );


    if(_dateTime.minute == _time.minute && _dateTime.hour == _time.hour && flag==0 && switch_value) {
      print(play);
      flag++;
      if (flag==1) {
        FlutterRingtonePlayer.playRingtone();
      }
      //this.play = false;
    }
    else if(_dateTime.minute != _time.minute || _dateTime.hour != _time.hour) {
      FlutterRingtonePlayer.stop();
      flag = 0;
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        padding: EdgeInsets.only(top: 20),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.timer),
            title: GestureDetector(
              child: Text(
                "${_time.hour}:${_time.minute}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                selectTime(context);
              },
            ),
            subtitle: Text(
              "Cycle: Every Day",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            trailing: Switch(
              value: switch_value,
              onChanged: (bool state) {
                setState(() {
                  this.switch_value = state;
                  print(switch_value);
                  if(switch_value)
                    FlutterRingtonePlayer.playRingtone();
                  else
                    FlutterRingtonePlayer.stop();
                });
              },
            ),
          ),
          elevation: 10,
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Set Alarm',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Null> selectTime(BuildContext context) async {
    picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if(picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<Null> alarm(BuildContext context) async {
    print("hello");
    await AndroidAlarmManager.periodic(const Duration(minutes: 1), alarmId, printHello);
  }

  void printHello() {
    final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
  }



}
