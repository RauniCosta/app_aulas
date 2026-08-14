import 'package:bibliotecalersaber/views/cadastro_screen.dart';
import 'package:bibliotecalersaber/views/login_screen.dart';
import 'package:bibliotecalersaber/views/menu_screen.dart';
import 'package:flutter/material.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca LerSaber',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 102, 139, 0), // Tom Vinho/ETEC
          primary: const Color(0xFF8B0000),
          secondary: const Color(0xFF4A4A4A), // Neutro
        ),
      ),

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/cadastro': (context) =>
            const CadastroScreen(), // <-- Nova rota adicionada
      },
    );
  }
}
