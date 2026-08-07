import 'package:flutter/material.dart';
import 'screens/setup_wizard.dart';
import 'screens/painel_tv.dart';
import 'screens/admin_panel.dart';

void main() {
  runApp(const GestorSalasApp());
}

class GestorSalasApp extends StatelessWidget {
  const GestorSalasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Alocação de Salas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      // Definimos qual página abre primeiro
      initialRoute: '/',
      // Mapa de rotas do sistema
      routes: {
        '/': (context) => const MenuInicial(),
        '/tv': (context) => const PainelTV(),
        '/admin': (context) => const AdminPanel(),
        '/setup': (context) => SetupWizard(), // Rota de cadastro inicial
      },
    );
  }
}

// Uma tela simples para escolher o modo de operação
class MenuInicial extends StatelessWidget {
  const MenuInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "GESTOR DE SALAS - QUARTA MANHÃ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.tv),
              label: const Text("ABRIR MODO TV"),
              onPressed: () => Navigator.pushNamed(context, '/tv'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("ABRIR CONSOLE ADMIN"),
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
            ),
          ],
        ),
      ),
    );
  }
}
