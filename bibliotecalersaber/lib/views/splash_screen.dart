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
        //child é um widget que centraliza seu filho na tela
        //o Child aceitas os seguinte widgets: Column, Row, Stack, Container, etc.

        child: Column(
          //mainAxisAlignment é uma propriedade que define o alinhamento dos filhos na direção principal (vertical para Column, horizontal para Row)
          mainAxisAlignment: MainAxisAlignment.center,

          //children é uma lista de widgets que serão exibidos na tela
          //O children aceita os seguintes widgets: Text, Icon, Image, etc.
          children: const [
            Icon(Icons.menu_book, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Biblioteca LerSaber',
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