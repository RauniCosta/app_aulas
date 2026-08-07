import 'package:flutter/material.dart';

class Telalabirinto extends StatelessWidget {
  //A Matriz: Planta do labirinto
  //1 = Parede
  //0 = Espaço livre
  //2 = Partida
  //3 = Chegada
  final List<List<int>> mapaDoLabirinto = [
    [1, 1, 1, 1, 1],
    [1, 0, 0, 0, 1],
    [1, 0, 1, 0, 1],
    [1, 2, 1, 3, 1],
    [1, 1, 1, 1, 1],
  ];

  @override
  Widget build(BuildContext context) {
    //Descobrindo o tamanho da Matriz
    int linhas = mapaDoLabirinto.length;
    int colunas = mapaDoLabirinto[0].length;

    return Scaffold(
      //AspectRatio mantém as proporções dos quadrados perfeitas na tela
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: colunas / linhas,

          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(), //Impede que o labirinto role como pagina de internet
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: colunas,
            ),
          ),
        ),
      ),
    );
  }
}
