// lib/main.dart

// 1. Importação fundamental: Traz todas as ferramentas visuais (Widgets) do Flutter.
import 'package:flutter/material.dart';
import 'package:labirinto_v2/homePage.dart'; //Biblioteca para usar o Timer!

// 2. Função principal: É aqui que o aplicativo começa a rodar.
void main() {
  // runApp "liga" o nosso aplicativo na tela do celular.
  runApp(homePage());
}
