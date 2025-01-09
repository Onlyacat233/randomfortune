import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:async';

const namelistPath = "./namelist.txt";
Logger logger = Logger("Random Fortune");

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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
  final Player player = Player(
    configuration: PlayerConfiguration(
      title: "Random Fortune!",
      ready: () {
        logger.fine("Player was Initialized");
      },
    ),
  );
  final Playable music = Media("asset://assets/background.mp3");

  void _updateCurrentText(timer) {
    startedNotifier.changeCurrentText(namelist[_index++ % namelist.length]);
  }

  @override
  Widget build(BuildContext context) {
    if (File(namelistPath).existsSync()) {
      namelist = File(namelistPath).readAsStringSync().split("\n");
    }
    player.setPlaylistMode(PlaylistMode.loop);
    player.open(music);
    player.pause();

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
              (context, child) => Text(
                startedNotifier.isStarted ? "暂停" : "开始",
                style: DefaultTextStyle.of(
                  context,
                ).style.apply(fontSizeDelta: 8),
              ),
        ),
        onPressed: () {
          startedNotifier.changeStartedStatus();
          if (startedNotifier.isStarted) {
            _timer = Timer.periodic(
              Duration(milliseconds: 10),
              _updateCurrentText,
            );
          } else {
            _timer.cancel();
          }
          player.playOrPause();
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
