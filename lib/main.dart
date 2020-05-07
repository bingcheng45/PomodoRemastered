import 'package:flutter/material.dart';
import 'package:pomodororemastered/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Pomodoro',
      theme: ThemeData(
        primaryColor: Color(0xfffd9193),
        textSelectionColor: Colors.white,
        primaryColorDark: Color(0xff68c89c),
      ),
      home: Home(),
    );
  }
}