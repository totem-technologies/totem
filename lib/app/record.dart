import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  String statusText = '';
  bool isComplete = false;
  String timeString = '00:00';
  Stopwatch stopwatch = Stopwatch();
  late AudioPlayer audioPlayer;

  late Timer timer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Record Page'),
        ),
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    startRecord();
                  },
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(color: Colors.red.shade300),
                    child: Center(
                      child: Text(
                        'start',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    pauseRecord();
                  },
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(color: Colors.blue.shade300),
                    child: Center(
                      child: Text(
                        RecordMp3.instance.status == RecordStatus.PAUSE
                            ? 'resume'
                            : 'pause',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    stopRecord();
                  },
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(color: Colors.green.shade300),
                    child: Center(
                      child: Text(
                        'stop',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                Text(
                  statusText,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
                Text(timeString)
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              play();
            },
            child: Container(
              margin: EdgeInsets.only(top: 30),
              alignment: AlignmentDirectional.center,
              width: 100,
              height: 50,
              child: isComplete
                  ? Text(
                      'play',
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    )
                  : Container(),
            ),
          ),
        ]),
      ),
    );
  }

  ///Timer
  void start() {
    stopwatch.start();
    timer = Timer.periodic(Duration(seconds: 1), update);
  }

  void update(Timer t) {
    if (stopwatch.isRunning) {
      setState(() {
        timeString =
            (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
                ':' +
                (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
      });
    }
  }

  void stop() {
    setState(() {
      timer.cancel();
      stopwatch.stop();
    });
  }

  void reset() {
    timer.cancel();
    stopwatch.reset();
    setState(() {
      timeString = '00:00:00';
    });
    stopwatch.stop();
  }

  ///Audio Record
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    var hasPermission = await checkPermission();
    if (hasPermission) {
      start(); //timer start
      statusText = 'Recording...';
      recordFilePath = await getFilePath();
      isComplete = false;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = 'Record error--->$type';
        setState(() {});
      });
    } else {
      statusText = 'No microphone permission';
    }
    setState(() {});
  }

  void pauseRecord() {
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      var s = RecordMp3.instance.resume();
      if (s) {
        statusText = 'Recording...';
        start();
        setState(() {});
      }
    } else {
      var s = RecordMp3.instance.pause();
      if (s) {
        statusText = 'Recording pause...';
        stop();
        setState(() {});
      }
    }
  }

  void stopRecord() {
    var s = RecordMp3.instance.stop();
    if (s) {
      statusText = 'Record complete';
      isComplete = true;
      reset();
      setState(() {});
    }
  }

  void resumeRecord() {
    var s = RecordMp3.instance.resume();
    if (s) {
      statusText = 'Recording...';
      setState(() {});
    }
  }

  late String recordFilePath;

  void play() {
    if (File(recordFilePath).existsSync()) {
      audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath, isLocal: true);
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    var storageDirectory = await getApplicationDocumentsDirectory();
    var sdPath = storageDirectory.path + '/record';
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + '/test_${i++}.mp3';
  }
}
