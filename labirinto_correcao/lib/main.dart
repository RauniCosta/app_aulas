import 'package:flutter/material.dart';
import 'package:fuga_felina/homePage.dart';



void main() {
   // runApp "liga" o nosso aplicativo na tela do celular.
  runApp(MeuJogoApp());
}

class MeuJogoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Tira a faixa de "debug" do canto da tela
      title:
          'Fuga Felina', // Nome do aplicativo (aparece na lista de apps)
      // Scaffold é a "estrutura" básica de uma tela (tela em branco)
      home:
          TelaDoJogo(), // Aqui é onde colocamos o Widget que criamos para o jogo
    );
  }
}


