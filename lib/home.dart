import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pomodororemastered/global.dart' as globals;
import 'package:rect_getter/rect_getter.dart';
import 'package:pomodororemastered/settings.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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
  bool quater1Opacity = false;
  bool quater2Opacity = false;
  bool quater3Opacity = false;
  bool quater4Opacity = false;
  double imageSize = 10;
  bool explode = false;
  double explodeWidth = 10;
  double explodeHeight = 10;
  double explodePadding = 16;
  String endOfTimer;
  AudioPlayer audioPlugin = AudioPlayer();

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

  //notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  void _showNotification(int totalSeconds, String text) async {
    await _demoNotification2(totalSeconds, text);
  }

  Future<void> _demoNotification2(int totalSeconds, String text) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 10));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.Max,
        icon: null,
        sound: RawResourceAndroidNotificationSound('that_was_quick'),
        color: Colors.red,
        enableVibration: true,
        playSound: true,
        ticker: 'test ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(0, 'Simple Pomodoro', text,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  // Future<void> _demoNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'channel_ID', 'channel name', 'channel description',
  //       importance: Importance.Max,
  //       priority: Priority.High,
  //       ticker: 'test ticker');

  //   var iOSChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(0, 'Hello, buddy',
  //       'A message from flutter buddy', platformChannelSpecifics,
  //       payload: 'test oayload');
  // }

  //end of notification

  @override
  void initState() {
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

    _load('that_was_quick.mp3', 'endOfTimer');


    initializationSettingsAndroid =
        AndroidInitializationSettings('notification_logo');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    //Timer.periodic(Duration(seconds: 1), (Timer t) => _setTime());//runs forever
  }

  Future<Null> _load(String filename, String soundType) async {
    final ByteData data = await rootBundle.load('assets/$filename');
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

    if (soundType == 'endOfTimer') {
      endOfTimer = tempFile.uri.toString();
    }
  }

  void _playSound(String soundName) {
    if (endOfTimer != null && soundName == 'endOfTimer') {
      audioPlugin.play(endOfTimer, isLocal: true);
    } 
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SecondRoute()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondRoute()));
                  },
                )
              ],
            ));
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
            longbreakCounterAnimation(),
            explodeOnFourthCompleted(),
          ],
        ),
      ),
    );
  }

  Widget explodeOnFourthCompleted() {
    //TODO: Explode animation
    return Positioned(
      left: 0,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: explodePadding, top: explodePadding),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 1000),
            opacity: explode ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              curve: Curves.fastOutSlowIn,
              width: explodeWidth,
              height: explodeHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(500),
              ),
            ),
          ),
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
      new Duration(seconds: _start), //TODO: change timer settings _start
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
        setState(() {
          globals.longBreakCounter++;
        });
      }
      _playSound('endOfTimer');
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

  void onFinished() async {
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
      if (globals.longBreakCounter % 4 == 0 && globals.longBreakCounter != 0) {
        setState(() {
          breakText = 'Let\'s enjoy our well deserved long break!';
        });
        setupTimer(globals.globalBreakTimer * 3);
      } else {
        setState(() {
          breakText = 'Take a short break!';
        });
        setupTimer(globals.globalBreakTimer);
      }
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
          Future.delayed(const Duration(milliseconds: 100), () async {
            await flutterLocalNotificationsPlugin.cancelAll();
          });
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
            try {
              if (globals.isRunning == false) {
                if (globals.index == 0) {
                  _showNotification(
                      globals.globalTimer, 'Time for your break.');
                } else {
                  _showNotification(globals.globalBreakTimer, 'Break is over!');
                }
                startTimer();
                setState(() {
                  globals.isRunning = true;
                  updateQuaterVisibility(); //TODO: make the quater have animations
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
            } catch (err) {}
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

  void explodeNow() {
    //TODO: explodenow
    setState(() {
      explodeWidth = MediaQuery.of(context).size.height * 0.5;
      explodeHeight = MediaQuery.of(context).size.height * 0.5;
      explodePadding = MediaQuery.of(context).size.width * 0.1;
      explode = true;
    });
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        explode = false;
      });
    });
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        explodeWidth = 10;
        explodeHeight = 10;
        explodePadding = 16;
      });
    });
  }

  void hideQuaterImages() {
    setState(() {
      quater1Opacity = false;
      quater2Opacity = false;
      quater3Opacity = false;
      quater4Opacity = false;
    });
  }

  //TODO: update quater visibility
  void updateQuaterVisibility() {
    setState(() {
      Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (!globals.isRunning) {
          timer.cancel();
          if (globals.longBreakCounter % 4 == 0 &&
              globals.longBreakCounter != 0) {
            //this is the 4th and completed pomodoro
            hideQuaterImages();
            if (globals.index == 1) {
              explodeNow();
            }
          } else {
            hideQuaterImages();
          }
          print('inside cancel $quater1Opacity');
        } else {
          if (globals.longBreakCounter % 4 == 0) {
            //working on the first pomodoro
            setState(() {
              quater1Opacity = !quater1Opacity;
              quater2Opacity = false;
              quater3Opacity = false;
              quater4Opacity = false;
            });
          } else if ((globals.longBreakCounter) % 4 == 1) {
            //working on the second pomodoro, finished the first
            setState(() {
              quater1Opacity = true;
              quater2Opacity = !quater2Opacity;
              quater3Opacity = false;
              quater4Opacity = false;
            });
          } else if ((globals.longBreakCounter) % 4 == 2) {
            //working on the third pomodoro, finished the second
            setState(() {
              quater1Opacity = true;
              quater2Opacity = true;
              quater3Opacity = !quater3Opacity;
              quater4Opacity = false;
            });
          } else if ((globals.longBreakCounter) % 4 == 3) {
            //working on the fourth pomodoro, finished the third
            setState(() {
              quater1Opacity = true;
              quater2Opacity = true;
              quater3Opacity = true;
              quater4Opacity = !quater4Opacity;
            });
          }

          // quater1Opacity = !quater1Opacity;
          // quater2Opacity = !quater2Opacity;
          // quater3Opacity = !quater3Opacity;
          // quater4Opacity = !quater4Opacity;
          print(
              'outside cancel $quater1Opacity long break is ${globals.longBreakCounter}');
        }
      });
    });
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
          child: AutoSizeText(
            (globals.index == 0) ? pomodoroText : breakText,
            style: TextStyle(
              color: Theme.of(context).textSelectionColor,
              fontSize: 30,
            ),
            maxLines: 1,
            wrapWords: true,
            textAlign: TextAlign.center,
            overflowReplacement: AutoSizeText(
              (globals.index == 0) ? pomodoroText : breakText,
              style: TextStyle(
                color: Theme.of(context).textSelectionColor,
                fontSize: 30,
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

  Widget longbreakCounterAnimation() {
    return Positioned(
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSize(
          vsync: this,
          duration: Duration(milliseconds: 100),
          child: Container(
            height: imageSize * 4,
            width: imageSize * 4,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    //TODO: quater images
                    AnimatedOpacity(
                      opacity: quater4Opacity ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 500),
                        child: Image.asset('images/quater4.png',
                            height: imageSize,
                            width: imageSize,
                            color: Colors.white),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: quater1Opacity ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 500),
                        child: Image.asset('images/quater1.png',
                            height: imageSize,
                            width: imageSize,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AnimatedOpacity(
                      opacity: quater3Opacity ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 500),
                        child: Image.asset('images/quater3.png',
                            height: imageSize,
                            width: imageSize,
                            color: Colors.white),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: quater2Opacity ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 500),
                        child: Image.asset('images/quater2.png',
                            height: imageSize,
                            width: imageSize,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  //Image.asset('images/logo.png', height: 24, width: 24,),

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

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('AlertPage'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('go back...'),
        ),
      ),
    );
  }
}
