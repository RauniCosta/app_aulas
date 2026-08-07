import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AudioPlayer.global.setAudioContext(
    AudioContext(
      android: const AudioContextAndroid(
        stayAwake: true,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus:
            AndroidAudioFocus.gainTransientMayDuck, // Não corta o som de fundo
      ),
    ),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MeuJogoApp());
}

class MeuJogoApp extends StatelessWidget {
  const MeuJogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fazbear Maze',
      theme: ThemeData(
        brightness: Brightness.dark, // Define o tema geral como escuro
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
