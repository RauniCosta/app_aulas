// Ficheiro: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // NOVO
import 'package:edusync/core/routing/auth_gate.dart';
import 'package:edusync/core/theme/app_theme.dart';
import 'firebase_options.dart'; // NOVO - Ficheiro gerado no Passo 3


void main() async {
  // 1. OBRIGATÓRIO: Garante que os bindings do Flutter estão prontos antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. INICIALIZA O FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // O Riverpod continua a envolver a app
    const ProviderScope(
      child: EduSync(),
    ),
  );
}

class EduSync extends StatelessWidget {
  const EduSync({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduSync', // Novo nome do projeto!
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // APLICA O TEMA GLOBAL AQUI!
      home: const AuthGate(),
    );
  }
}