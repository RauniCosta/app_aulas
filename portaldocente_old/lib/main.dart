// Ficheiro: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // NOVO
import 'package:portaldocente/core/routing/auth_gate.dart';
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
      child: EducaLinkApp(),
    ),
  );
}

class EducaLinkApp extends StatelessWidget {
  const EducaLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EducaLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3B68A8),
        fontFamily: 'Roboto',
      ),
      // O AuthGate é o widget que decide qual tela mostrar com base no estado de autenticação
      home: const AuthGate(), 
    );
  }
}