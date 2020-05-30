import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pomodororemastered/global.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter/cupertino.dart';

class Settings extends StatefulWidget {
  final Function setupTimer;
  final Function setupBreakTimer;

  Settings(this.setupTimer, this.setupBreakTimer);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Duration workTimer;
  Duration workTimerTemp;
  final hKeyW = 'hour_key_work';
  final mKeyW = 'minute_key_work';
  int wHour, wMinute;
  double _opacity = 0;

  final cKey = 'completed_pomodoros';
  int completed = 0;

  //break timer
  Duration breakTimer;
  Duration breakTimerTemp;
  final hKeyB = 'hour_key_break';
  final mKeyB = 'minute_key_break';
  int bHour, bMinute;
  double _opacityB = 1;
  String breakText = 'You cannot set timer to 0 hours and 0 minute!';
  Color breakTextColor = Colors.red;
  bool isZero = false;
  //'After 4 pomodoro it will be a long break that is ${getMinute(globals.globalBreakTimer * 3)} minute.';

  @override
  void initState() {
    super.initState();
    _getWorkTimer().then((list) {
      setState(() {
        wHour = list[0];
        wMinute = list[1];
        workTimer = Duration(hours: wHour, minutes: wMinute);
      });
    });
    _getBreakTimer().then((list) {
      setState(() {
        bHour = list[0];
        bMinute = list[1];
        breakTimer = Duration(hours: bHour, minutes: bMinute);
      });
    });
    _getCompletedNumber().then((value) {
      setState(() {
        completed = value;
        print('completed pomod: $completed');
      });
    });
  }

  int getMinute(int current) {
    return current ~/ 60;
  }

  Future<int> _getCompletedNumber() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt(cKey) ?? 0;
    return num;
  }

  void _setWorkTimer(hour, minutes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(hKeyW, hour);
    prefs.setInt(mKeyW, minutes);
  }

  Future<List<int>> _getWorkTimer() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt(hKeyW) ?? 0;
    int minute = prefs.getInt(mKeyW) ?? 25;
    return [hour, minute];
  }

  void _setBreakTimer(hour, minutes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(hKeyB, hour);
    prefs.setInt(mKeyB, minutes);
  }

  Future<List<int>> _getBreakTimer() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt(hKeyB) ?? 0;
    int minute = prefs.getInt(mKeyB) ?? 5;
    return [hour, minute];
  }

  Widget timerPicker(context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      title: Text("Edit work timer"),
      backgroundColor: Colors.white,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                child: CupertinoTimerPicker(
                  initialTimerDuration:
                      Duration(hours: wHour, minutes: wMinute),
                  minuteInterval: 1, //TODO: change back to 5
                  backgroundColor: Colors.white,
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (value) {
                    setState(() {
                      workTimerTemp = value;
                      if (value.inHours == 0 && (value.inMinutes % 60) == 0) {
                        _opacity = 1;
                      } else {
                        _opacity = 0;
                      }
                    });
                  },
                ),
              ),
              Opacity(
                opacity: _opacity,
                child: Container(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 0, left: 15, right: 15),
                  child: Text(
                    'You cannot set timer to 0 hours and 0 minute!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            workTimerTemp = workTimer;
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            saveWorkTime(context);
          },
        ),
      ],
    );
  }

  //break timer
  Widget timerPickerB(context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      title: Text("Edit break timer"),
      backgroundColor: Colors.white,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                child: CupertinoTimerPicker(
                  initialTimerDuration:
                      Duration(hours: bHour, minutes: bMinute),
                  minuteInterval: 1,
                  backgroundColor: Colors.white,
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (value) {
                    setState(() {
                      breakTimerTemp = value;
                      if (value.inHours == 0 && (value.inMinutes % 60) == 0) {
                        //_opacityB = 1;
                        isZero = true;
                        breakText =
                            'You cannot set timer to 0 hours and 0 minute!';
                        breakTextColor = Colors.red;
                      } else {
                        //_opacityB = 0;
                        isZero = false;
                        breakText =
                            'After 4 pomodoro it will be a long break that is ${(value.inSeconds * 3) ~/ 3600}hour ${beautifyNumber((value.inMinutes * 3) % 60)}minute.';
                        breakTextColor = Colors.black;
                      }
                    });
                  },
                ),
              ),
              Opacity(
                opacity: _opacityB,
                child: Container(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 0, left: 15, right: 15),
                  child: AutoSizeText(
                    breakText,
                    style: TextStyle(color: breakTextColor, fontSize: 20),
                    maxLines: 2,
                    maxFontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            breakTimerTemp = breakTimer;
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            saveBreakTime(context);
          },
        ),
      ],
    );
  }

  String beautifyNumber(int num) {
    return num < 10 ? '0$num' : '$num';
  }

  void saveWorkTime(context) {
    setState(() {
      if (_opacity == 1) {
        //do nothing
      } else {
        workTimer = workTimerTemp;
        wHour = workTimer.inHours;
        wMinute = workTimer.inMinutes % 60;
        _setWorkTimer(wHour, wMinute);
        globals.globalTimer = workTimer.inSeconds;
        if (globals.isRunning == false) {
          widget.setupTimer(globals.globalTimer);
        }
        print("hopefully change the timer by now : " +
            globals.globalTimer.toString());
        Navigator.of(context).pop();
      }
    });
  }

  //break timer
  void saveBreakTime(context) {
    setState(() {
      if (isZero) {
        //do nothing
      } else {
        breakTimer = breakTimerTemp;
        bHour = breakTimer.inHours;
        bMinute = breakTimer.inMinutes % 60;
        _setBreakTimer(bHour, bMinute);
        globals.globalBreakTimer = breakTimer.inSeconds;
        if (globals.isRunning == false) {
          if (globals.longBreakCounter % 4 == 0 &&
              globals.longBreakCounter != 0) {
            widget.setupTimer(globals.globalBreakTimer * 3);
          } else {
            widget.setupBreakTimer(globals.globalBreakTimer);
          }
        }

        print("hopefully change the break timer by now : " +
            globals.globalBreakTimer.toString());
        Navigator.of(context).pop();
      }
    });
  }

  Widget editWorkTimer() {
    return ListTile(
      title: FittedBox(
        child: Text(
          "Curent Duration:",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      trailing: FittedBox(
        child: Container(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$wHour ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: 'hour '),
                TextSpan(
                  text: '$wMinute ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: 'minute '),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return timerPicker(context);
          },
        );
      },
    );
  }

  //break timer
  Widget editBreakTimer() {
    return ListTile(
      title: FittedBox(
        child: Text(
          "Curent Duration:",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      trailing: FittedBox(
        child: Container(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$bHour ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: 'hour '),
                TextSpan(
                  text: '$bMinute ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: 'minute '),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return timerPickerB(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _getCompletedNumber().then((value) {
      setState(() {
        completed = value;
      });
    });
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: globals.bgColor[globals.index],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'Pomodoro work duration',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          editWorkTimer(),
          ListTile(
            title: Text(
              'Pomodoro break duration',
              style: TextStyle(
                fontSize: 20,
                color: globals.bgColor[1],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          editBreakTimer(),
          ListTile(
            title: Center(
              child: Text(
                'You can long press to skip the timer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            title: Center(
              child: Text(
                'Completed Pomodoros :',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            title: Center(
              child: AutoSizeText(
                completed.toString(),
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
