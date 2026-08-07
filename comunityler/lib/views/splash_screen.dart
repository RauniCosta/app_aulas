// splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navegarParaLogin();
  }

  // Função assíncrona para simular um tempo de carregamento
  _navegarParaLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    // Navega para o Login e remove a Splash da pilha de telas
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900, // Cor de fundo da biblioteca
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Biblioteca ComunityLer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white), // Indicador de carregamento
          ],
        ),
      ),
    );
  }
}