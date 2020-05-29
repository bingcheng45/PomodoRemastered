import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodororemastered/global.dart' as globals;
import 'package:rect_getter/rect_getter.dart';
import 'package:pomodororemastered/settings.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  final hKeyW = 'hour_key_work';
  final mKeyW = 'minute_key_work';
  final hKeyB = 'hour_key_break';
  final mKeyB = 'minute_key_break';
  final cKey = 'completed_pomodoros';

  List workList = [
    'I work hard because I love my work. ~ Bill Gates, Microsoft co-founder',
    'I do not know anyone who has got to the top without hard work. That is the recipe. It will not always get you to the top, but should get you pretty near. ~ Margaret Thatcher, Former UK Prime Minister',
    'Success seems to be connected with action. Successful people keep moving. They make mistakes, but they don’t quit. ~ Conrad Hilton, hotelier and business magnate',
    'Success is no accident. It is hard work, perseverance, learning, studying, sacrifice and most of all, love of what you are doing or learning to do. ~ Pele, Brazilian soccer player',
    'The successful warrior is the average man, with laser-like focus. ~ Bruce Lee, martial artist and movie star',
    'If you really look closely, most overnight successes took a long time. ~ Steve Jobs, co-Founder of Apple Inc.',
    'Talent is cheaper than table salt. What separates the talented individual from the successful one is hard work. ~ Stephen King, American author',
    'The only difference between success and failure is the ability to take action. ~ Alexander Graham Bell, Inventor',
    'Luck is a dividend of sweat. The more you sweat, the luckier you get. ~ Ray Kroc, American fast food tycoon',
    'It’s not about money or connection — it’s the willingness to outwork and outlearn everyone. ~ Mark Cuban, American investor',
    'Doing the best at this moment puts you in the best place for the next moment. ~ Oprah Winfrey, media mogul',
    'I think that my biggest attribute to any success that I have had is hard work. There really is no substitute for working hard. ~ Maria Bartiromo, television journalist and author',
    'If you love your work, you’ll be out there every day trying to do it the best you possibly can, and pretty soon everybody around will catch the passion from you – like a fever. ~ Sam Walton, founder of Walmart',
    'Nothing is particularly hard if you divide it into small jobs. ~ Henry Ford, American industrialist',
    'Work hard, have fun, make history. ~ Jeff Bezos, Amazon founder                     ',
    'I never took a day off in my 20s. Not one. ~ Bill Gates, Microsoft co-founder',
    'Hard work beats talent if talent doesn’t work hard. ~ Tim Notke, basketball coach',
    'Men die of boredom, psychological conflict and disease. They do not die of hard work. ~ David Ogilvy, advertising business tycoon',
    'The only place where success comes before work is in the dictionary. ~ Vidal Sassoon, hairdressing business tycoon',
    'No matter how hard you work, someone else is working harder. ~ Elon Musk, entrepreneur',
    'Success isn\'t always about greatness. It\'s about consistency. Consistent hard work leads to success. Greatness will come. ~ Dwayne “The Rock” Johnson, actor',
    'People who say it cannot be done should not interrupt those who are doing it. ~ George Bernard Shaw, playwright',
    'You are your greatest asset. Put your time, effort and money into training ~ Tom Hopkins, sales leader',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //globals.globalTimer = _totalSeconds; //set global timer to shared pref timer
    _getWorkTimer().then((list) {
      setState(() {
        globals.globalTimer =
            60 * (list[0] * 60 + list[1]); //hours and minutes to seconds
        setupTimer(globals.globalTimer);
      });
    });
    _getBreakTimer().then((list) {
      setState(() {
        globals.globalBreakTimer =
            60 * (list[0] * 60 + list[1]); //hours and minutes to seconds
        setupBreakTimer(globals.globalBreakTimer);
      });
    });
    //worktime
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: globals.bgColor[globals.index]),
    );
  }

  String generateWorkText() {
    var rng = Random();
    return workList[rng.nextInt(workList.length - 1)];
  }

  Future<List<int>> _getWorkTimer() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt(hKeyW) ?? 0;
    int minute = prefs.getInt(mKeyW) ?? 25;
    return [hour, minute];
  }

  Future<List<int>> _getBreakTimer() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt(hKeyB) ?? 0;
    int minute = prefs.getInt(mKeyB) ?? 5;
    return [hour, minute];
  }

  void setupTimer(int totalSeconds) {
    setState(() {
      _start = totalSeconds;
      _current = totalSeconds;
      minute = getMinute(totalSeconds);
      seconds = getSeconds(totalSeconds);
    });
  }

  void setupBreakTimer(int totalSeconds) {
    if (globals.index == 0) {
      //do nth
    } else {
      setupTimer(totalSeconds);
    }
  }

  int getMinute(int current) {
    return _current ~/ 60;
  }

  int getSeconds(int current) {
    return current % 60;
  }

  String beautifyNumber(int num) {
    return num < 10 ? '0$num' : '$num';
  }

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
      if (globals.index == 0) {
        _updateCompleted();
      }
      onFinished();
      sub.cancel();
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: globals.bgColor[globals.index]),
      );
    });
  }

  void _updateCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt(cKey) ?? 0;
    prefs.setInt(cKey, num + 1);
    print('updating num $num');
  }

  void onFinished() {
    print("Done");
    setState(() {
      globals.isRunning = false;
      switchBGColor();
      firstTap = false;
    });

    if (globals.index == 0) {
      //pomodoro timer
      setupTimer(globals.globalTimer);
      pomodoroText = 'Tap to begin';
    } else {
      //break timer
      setupTimer(globals.globalBreakTimer);
      breakText = 'Take a short break!';
    }
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
        onFinished();
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
              startTimer();
              setState(() {
                globals.isRunning = true;
                _btmTextVisible = !_btmTextVisible;
                print('non delayed $_btmTextVisible');
                pomodoroText = '';
                breakText = '';
                Future.delayed(const Duration(milliseconds: 1000), () {
                  setState(() {
                    _btmTextVisible = !_btmTextVisible;
                    if (globals.index == 0) {
                      if (globals.isRunning == false) {
                        pomodoroText = 'Tap to begin';
                      } else {
                        pomodoroText = generateWorkText();
                      }
                    } else {
                      if (globals.isRunning == false) {
                        breakText = 'Take a short break!';
                      } else {
                        breakText = 'Enjoy your well deserved break!';
                      }
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
                      ? EdgeInsets.only(top: height * 0.29)
                      : EdgeInsets.only(top: height * 0.09),
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: FittedBox(
                    child: topText(context),
                  ),
                ),
                AnimatedContainer(
                  padding: firstTap
                      ? EdgeInsets.only(top: height * 0.29)
                      : EdgeInsets.only(top: height * 0.49),
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: bottomText(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topText(context) {
    double paddingW = MediaQuery.of(context).size.width * 0.1;
    //double paddingH = MediaQuery.of(context).size.height * paddingheightTop;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingW),
      child: Opacity(
        opacity: 1,
        child: Text(
          '${beautifyNumber(getMinute(minute))} : ${beautifyNumber(getSeconds(seconds))}',
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
    //double paddingW = MediaQuery.of(context).size.width * 0.1;
    //double paddingH = MediaQuery.of(context).size.height * paddingheightBtm;
    return AnimatedOpacity(
      opacity: _btmTextVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      //curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Opacity(
          opacity: 0.7,
          child: (globals.isRunning == false)
              ? AutoSizeText(
                  (globals.index == 0) ? pomodoroText : breakText,
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                    fontSize: 50,
                  ),
                  maxLines: 1,
                )
              : AutoSizeText(
                  (globals.index == 0) ? pomodoroText : breakText,
                  style: TextStyle(
                    color: Theme.of(context).textSelectionColor,
                    fontSize: 50,
                  ),
                  maxLines: 1,
                  wrapWords: false,
                  textAlign: TextAlign.center,
                  overflowReplacement: AutoSizeText(
                    (globals.index == 0) ? pomodoroText : breakText,
                    style: TextStyle(
                      color: Theme.of(context).textSelectionColor,
                      fontSize: 50,
                    ),
                    maxLines: 3,
                    wrapWords: false,
                    textAlign: TextAlign.center,
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
          builder: (context) => Settings(setupTimer, setupBreakTimer),
        ))
        .then((_) => setState(() => rect = null));
  }

  Widget settingBtn() {
    return RectGetter(
      key: rectGetterKey,
      child: Positioned(
        //top: MediaQuery.of(context).padding.top,
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
