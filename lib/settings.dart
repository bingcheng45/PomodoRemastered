import 'package:flutter/material.dart';
import 'package:pomodororemastered/global.dart' as globals;

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
              'Pomodoro Work duration',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //editwork timer
        ],
      ),
    );
  }
}
