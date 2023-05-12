import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool firstPress = true;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }

    setState(() {});
  }

  void reset() {
    _stopwatch.reset();
    _stopwatch.stop();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: orientation == Orientation.portrait
              ? AppBar(
                  title: Text(
                    'Easy Stop-Watch',
                  ),
                  actions: [
                      IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset Stop-Watch',
                          onPressed: () {
                            if (firstPress) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Long press resets the time too!"),
                                duration: Duration(seconds: 2),                              
                              ));
                              firstPress = false;
                            }
                            reset();
                          }),
                    ])
              : null,
          body: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () {
                reset();
              },
              onTap: handleStartStop,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: height3 / 10,
                  ),
                  SizedBox(
                    height: height3 * 4 / 5,
                    child: Center(
                      child: formatTimeText(_stopwatch.elapsedMilliseconds, orientation),
                    ),
                  ),
                  SizedBox(
                      height: height3 / 10,
                      child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _stopwatch.isRunning
                                    ? 'Tap anywhere to Stop'
                                    : 'Tap anywhere to Start',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.robotoMono().fontFamily,
                                ),
                              ),
                            ],
                          ))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  RichText formatTimeText(int milliseconds, Orientation orientation) {
    var timeList = formatTime(milliseconds);
    var timeText = '';
    for (int i = 0; i < timeList.length - 1; i++) {
      if (i != 0) {
        timeText += ':';
      }
      timeText += timeList[i];
    }

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: timeText,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontFamily: 'RobotoCondensed',
              fontSize: orientation == Orientation.portrait ? 76.0 : 128.0,
            ),
          ),
          TextSpan(
            text: '.${timeList[timeList.length - 1]}',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontFamily: 'RobotoCondensed',
              color: Colors.grey.shade400,
              fontSize: orientation == Orientation.portrait ? 42.0 : 96.0,
            ),
          ),
        ],
      ),
    );
  }

  List<String> formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    var milisecs = ((milliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    if (hours == "00") {
      return [minutes, seconds, milisecs];
    }
    return [hours, minutes, seconds, milisecs];
  }
}
