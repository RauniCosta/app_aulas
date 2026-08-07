import 'package:flutter/material.dart';
import 'screens/lista_tarefas_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wsjiiqqwfdvpxshhqwgr.supabase.co',
    anonKey: 'sb_publishable_s8L8yCBfWJ2XrLJZy-MoAw_0oQ-0YqU',
  );
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