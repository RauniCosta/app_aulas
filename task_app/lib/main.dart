import 'package:flutter/material.dart';
import 'screens/lista_tarefas_screen.dart';

void main() {
  // ADICIONE ESTA LINHA: Garante que os plugins nativos (como o SQLite) funcionem
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MeuTaskApp());
}

class MeuTaskApp extends StatelessWidget {
  const MeuTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaTarefasScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}