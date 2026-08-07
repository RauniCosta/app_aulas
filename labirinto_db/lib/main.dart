// lib/main.dart

// 1. Importação fundamental: Traz todas as ferramentas visuais (Widgets) do Flutter.
import 'package:flutter/material.dart';
import 'package:labirinto_db/homePage.dart';

// 2. Função principal: É aqui que o aplicativo começa a rodar.
void main() {
  // runApp "liga" o nosso aplicativo na tela do celular.
  runApp(MeuJogoApp());
}

// 3. O Widget Raiz: Configurações gerais do app (sem estado mutável por enquanto).
class MeuJogoApp extends StatelessWidget {
  const MeuJogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Tira a faixa de "debug" do canto da tela
      title: 'Corrida de Labirintos',
      // Scaffold é a "estrutura" básica de uma tela (tela em branco)
      home: TelaDoJogo(),
    );
  }
}
