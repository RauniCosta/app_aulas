import 'package:exemplo_tela_login/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Aulas - ETEC',
      theme: ThemeData(
        // Definindo a cor primária global
        primarySwatch: Colors.red, 
        // Padronizando o tema de texto para todo o app
        textTheme: GoogleFonts.robotoFlexTextTheme(),
        // Estilização padrão para botões, facilitando para os alunos
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
        // Estilo padrão dos campos de texto (TextFields)
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginPage(),
    );
  }
}