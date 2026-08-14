import 'package:flutter/material.dart';

// A função principal (main) é o ponto de partida de qualquer aplicativo Flutter.
void main() {
  // runApp inicializa o aplicativo inflando o widget raiz na tela.
  runApp(const MeuApp());
}

// StatelessWidget é usado para compor a interface. São widgets que não guardam estado mutável.
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget raiz que envolve a aplicação com as configurações do Material Design (temas, navegação, etc).
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estrutura de Widgets',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF380394),
          primary: const Color(0xFF380394),
          secondary: const Color(0xFF02A352),
        ),
      ),
      // A propriedade 'home' define qual será a tela inicial do aplicativo.
      home: Scaffold(
        appBar: AppBar(title: const Text('Elementos Básicos')),
        // O 'body' é o espaço principal da tela.
        // Aqui usamos o Center para centralizar o widget filho tanto horizontal quanto verticalmente.
        body: Center(
          // O Column é um widget de layout que organiza seus filhos (children) em uma lista vertical.
          child: Column(
            // mainAxisAlignment alinha os elementos ao longo do eixo principal da Column (eixo Y).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Widget de Texto simples
              const Text(
                'Aqui está o seu texto!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Este é um exemplo de como usar widgets básicos no Flutter.',
                style: TextStyle(fontSize: 16, color: Color(0xFF02A352)),
              ),
              // SizedBox é frequentemente usado para criar espaçamento entre os widgets.
              const SizedBox(height: 50),
              // O Container é um widget extremamente versátil.
              // Neste caso, está configurado com largura, altura e cor para criar o "quadrado colorido".
              Container(
                width: 300,
                height: 150,
                color: Colors.orange, // Cor do quadrado
                alignment: Alignment.center,
                child: const Text(
                  'Quadrado',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
