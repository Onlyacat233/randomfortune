import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

const namelistPath = "./namelist.txt";

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var namelist = <String>[];
  int _index = 0;
  late Timer _timer;
  final StartedNotifier startedNotifier = StartedNotifier();
  final AudioPlayer player = AudioPlayer();

  void _updateCurrentText(timer) {
    startedNotifier.changeCurrentText(namelist[_index++ % namelist.length]);
  }

  @override
  Widget build(BuildContext context) {
    if (File(namelistPath).existsSync()) {
      namelist = File(namelistPath).readAsStringSync().split("\n");
    }
    player.setUrl("asset:///assets/background.mp3");

    return Scaffold(
      body: Center(
        child: ListenableBuilder(
          listenable: startedNotifier,
          builder:
              (context, child) => Text(
                startedNotifier.currentText,
                style: DefaultTextStyle.of(context).style.apply(
                  fontSizeFactor: MediaQuery.of(context).size.width / 70,
                  fontFamily: "Lishu",
                ),
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: ListenableBuilder(
          listenable: startedNotifier,
          builder:
              (context, child) => Text(startedNotifier.isStarted ? "暂停" : "开始"),
        ),
        onPressed: () {
          startedNotifier.changeStartedStatus();
          if (startedNotifier.isStarted) {
            player.play();
            _timer = Timer.periodic(
              Duration(milliseconds: 10),
              _updateCurrentText,
            );
          } else {
            _timer.cancel();
            player.pause();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class StartedNotifier extends ChangeNotifier {
  bool _isStarted = false;
  bool get isStarted => _isStarted;
  String _currentText = "准备抽奖!";
  String get currentText => _currentText;

  void changeStartedStatus() {
    _isStarted = !_isStarted;
    notifyListeners();
  }

  void changeCurrentText(newText) {
    _currentText = newText;
    notifyListeners();
  }
}
