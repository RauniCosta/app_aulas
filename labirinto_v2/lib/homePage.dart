import 'package:flutter/material.dart';
import 'package:labirinto_v2/homePageEstado.dart';

// 3. O Widget Raiz: Configurações gerais do app (sem estado mutável por enquanto).
class homePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Tira a faixa de "debug" do canto da tela
      title: 'Corrida de Labirintos',
      // Scaffold é a "estrutura" básica de uma tela (tela em branco)
      home: homePageEstado(),
    );
  }
}
