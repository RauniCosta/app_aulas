// menu_screen.dart
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Biblioteca'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // GridView permite criar uma grade responsiva de itens
        child: GridView.count(
          crossAxisCount: 2, // 2 itens por linha
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _construirBotaoMenu(context, Icons.library_books, 'Catálogo', Colors.orange),
            _construirBotaoMenu(context, Icons.history, 'Meus Empréstimos', Colors.blue),
            _construirBotaoMenu(context, Icons.bookmark, 'Reservas', Colors.green),
            _construirBotaoMenu(context, Icons.warning_amber, 'Multas', Colors.red),
            _construirBotaoMenu(context, Icons.person, 'Perfil', Colors.purple),
            _construirBotaoMenu(context, Icons.info, 'Sobre', Colors.grey),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para criar os botões do menu de forma padronizada (Reuso de Código)
  Widget _construirBotaoMenu(BuildContext context, IconData icone, String titulo, Color cor) {
    return InkWell(
      onTap: () {
        // Lógica de navegação para cada tela específica
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navegando para $titulo...')),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 50, color: cor),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}