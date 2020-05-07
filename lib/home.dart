import 'package:flutter/material.dart';
import 'package:pomodororemastered/global.dart' as globals;
import 'package:rect_getter/rect_getter.dart';
import 'package:pomodororemastered/settings.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          backgroundColor(),
          settingBtn(),
          _ripple(),
        ],
      ),
    );
  }

  Widget backgroundColor() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 700),
      curve: Curves.fastOutSlowIn,
      color: globals.bgColor[globals.index],
      child: Container(),
    );
  }


  //settings start
  void _onTap() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(
          animationDuration + delay, () => _goToNextPage());
    });
  }
  void _goToNextPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => Settings(),
        ))
        .then((_) => setState(() => rect = null));
  }

  Widget settingBtn() {
    return RectGetter(
      key: rectGetterKey,
      child: Positioned(
        top: MediaQuery.of(context).padding.top,
        right: 0,
        child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: Icon(Icons.settings),
            onPressed: () => _onTap()),
      ),
    );
  }

  Widget _ripple() {
    if (rect == null) {
      return Container();
    }
    return AnimatedPositioned(
      duration: animationDuration,
      left: rect.left,
      right: MediaQuery.of(context).size.width - rect.right,
      top: rect.top,
      bottom: MediaQuery.of(context).size.height - rect.bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
  //settings end
}
