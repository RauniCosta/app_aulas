// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importação do pacote Firebase
import 'firebase_options.dart'; // Ficheiro gerado automaticamente pelo FlutterFire

import 'views/cadastro_screen.dart';
import 'views/login_screen.dart';
import 'views/menu_screen.dart';
import 'views/splash_screen.dart';

// Transformamos a função main em assíncrona (async)
void main() async {
  // Garante que o motor do Flutter está a rodar antes de chamar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com a nuvem usando as credenciais geradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'comunityLer',
      theme: ThemeData(
        primarySwatch: const Color(0xFFA4A791),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/cadastro': (context) => const CadastroScreen(),
      },
    );
  }
}