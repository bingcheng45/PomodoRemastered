import 'package:flutter/material.dart';
import 'package:pomodororemastered/global.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart'; //TODO: do settings pages and im done betch
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

  //break timer
  Duration breakTimer;
  Duration breakTimerTemp;
  final hKeyB = 'hour_key_break';
  final mKeyB = 'minute_key_break';
  int bHour, bMinute;
  double _opacityB = 0;

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
      content: FittedBox(
        //fit: BoxFit.none,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoTimerPicker(
                  initialTimerDuration:
                      Duration(hours: wHour, minutes: wMinute),
                  minuteInterval: 5,
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
                Opacity(
                  opacity: _opacity,
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 0),
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
      content: FittedBox(
        //fit: BoxFit.none,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoTimerPicker(
                  initialTimerDuration:
                      Duration(hours: bHour, minutes: bMinute),
                  minuteInterval: 1,
                  backgroundColor: Colors.white,
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (value) {
                    setState(() {
                      breakTimerTemp = value;
                      if (value.inHours == 0 && (value.inMinutes % 60) == 0) {
                        _opacityB = 1;
                      } else {
                        _opacityB = 0;
                      }
                    });
                  },
                ),
                Opacity(
                  opacity: _opacityB,
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 0),
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
        widget.setupTimer(globals.globalTimer);
        print("hopefully change the timer by now : " +
            globals.globalTimer.toString());
        Navigator.of(context).pop();
      }
    });
  }

  //break timer
  void saveBreakTime(context) {
    setState(() {
      if (_opacityB == 1) {
        //do nothing
      } else {
        breakTimer = breakTimerTemp;
        bHour = breakTimer.inHours;
        bMinute = breakTimer.inMinutes % 60;
        _setBreakTimer(bHour, bMinute);
        globals.globalBreakTimer = breakTimer.inSeconds;
        widget.setupBreakTimer(globals.globalBreakTimer);
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
        ],
      ),
    );
  }
}
