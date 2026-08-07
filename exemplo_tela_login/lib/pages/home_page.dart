import 'package:exemplo_tela_login/pages/cadastro_page.dart';
import 'package:exemplo_tela_login/pages/login_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Principal"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Cabeçalho personalizado com dados do usuário (exemplo didático)
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
              accountName: Text("Aluno ETEC"),
              accountEmail: Text("aluno@etec.sp.gov.br"),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Início"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Cadastrar"),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer antes de navegar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroPage()),
                );
              },
            ),
            const Divider(), // Linha divisória
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Sair"),
              onTap: () {
                // Volta para a tela de login limpando a pilha de navegação
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text("Bem-vindo ao Sistema de Mobile!"),
      ),
    );
  }
}