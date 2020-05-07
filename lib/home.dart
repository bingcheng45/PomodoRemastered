import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodororemastered/global.dart' as globals;
import 'package:rect_getter/rect_getter.dart';
import 'package:pomodororemastered/settings.dart';
import 'package:quiver/async.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;
  String pomodoroText = 'Tap to begin';
  String breakText = 'Take a short break!';
  bool _btmTextVisible = true;
  int minute = 0;
  int seconds = 0;
  int _start = 0;
  int _current = 0;
  bool firstTap = false;
  CountdownTimer countDownTimer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            backgroundColor(),
            inkWellButton(context),
            settingBtn(),
            _ripple(),
          ],
        ),
      ),
    );
  }

  //background color start

  Widget backgroundColor() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 700),
      curve: Curves.fastOutSlowIn,
      color: globals.bgColor[globals.index],
      child: Container(),
    );
  }

  void switchBGColor() {
    setState(() {
      if (globals.index == 0) {
        globals.index = 1;
      } else {
        globals.index = 0;
      }
    });
  }

  //background color end

  //timerobject start
  var timerObj;
  //start the countdown timer
  void startTimer() {
    countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        globals.isRunning = true;
        _current = _start - duration.elapsed.inSeconds;
        seconds = _current;
        minute = _current;
      });
    });
    timerObj = sub;

    sub.onDone(() {
      //onFinished();
      sub.cancel();
    });
  }

  //timer object end

  //text display start

  Widget inkWellButton(context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: globals.bgColor[globals.index]),
    );
    return GestureDetector(
      onLongPressUp: () {
        //onFinished();
        try {
          timerObj.cancel();
        } catch (err) {
          print(err.toString());
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white54,
          onTap: () {
            if (globals.isRunning == false) {
              //_showNotification();
              //refreshTotalSeconds();
              //startTimer();
              setState(() {
                globals.isRunning = true;
                _btmTextVisible = !_btmTextVisible;
                print('non delayed $_btmTextVisible');
                Future.delayed(const Duration(milliseconds: 1000), () {
                  setState(() {
                    _btmTextVisible = !_btmTextVisible;
                    print('delayed $_btmTextVisible');
                    if (globals.index == 0) {
                      pomodoroText = 'Let\'s do it!';
                      breakText = 'Take a short break!';
                    } else {
                      breakText = 'Go scroll Facebook';
                      pomodoroText = 'Tap to begin';
                    }
                  });
                });
                if (!firstTap) {
                  firstTap = !firstTap; //change first tap to true if false.
                }
              });
            }
          },
          child: Container(
            height: height,
            width: width,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  padding: firstTap
                      ? EdgeInsets.only(top: height * 0.3)
                      : EdgeInsets.only(top: height * 0.1),
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: FittedBox(
                    child: topText(context),
                  ),
                ),
                AnimatedContainer(
                  padding: firstTap
                      ? EdgeInsets.only(top: height * 0.3)
                      : EdgeInsets.only(top: height * 0.5),
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: FittedBox(
                    child: bottomText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String beautifyNumber(int num) {
    return num < 10 ? '0$num' : '$num';
  }

  Widget topText(context) {
    double paddingW = MediaQuery.of(context).size.width * 0.1;
    //double paddingH = MediaQuery.of(context).size.height * paddingheightTop;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingW),
      child: Opacity(
        opacity: 1,
        child: Text(
          '${beautifyNumber(minute)} : ${beautifyNumber(seconds)}',
          style: TextStyle(
            color: Theme.of(context).textSelectionColor,
            fontSize: 78,
          ),
        ),

        //make a if statement with has hour to show hour
      ),
    );
  }

  Widget bottomText(context) {
    double paddingW = MediaQuery.of(context).size.width * 0.1;
    //double paddingH = MediaQuery.of(context).size.height * paddingheightBtm;
    return AnimatedOpacity(
      opacity: _btmTextVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingW),
        child: Opacity(
          opacity: 0.5,
          child: Text(
            (globals.index == 0) ? pomodoroText : breakText,
            style: TextStyle(
              color: Theme.of(context).textSelectionColor,
              fontSize: 54,
            ),
          ),
        ),
      ),
    );
  }

  //text display end

  //settings start
  void _onTap() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, () => _goToNextPage());
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
