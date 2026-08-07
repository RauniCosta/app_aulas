import 'package:flutter/material.dart';

class Meujogoapp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Labirinto',
      home: TelaLabirinto(),
    );
  }
}