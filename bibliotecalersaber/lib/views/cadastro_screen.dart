// cadastro_screen.dart
import 'package:flutter/material.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // Controladores para capturar o que o usuário digita (Preparação para a UC 13)
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta - comunityLer'),
        centerTitle: true,
        // O Flutter adiciona a seta de "voltar" automaticamente quando viemos de outra tela
      ),
      // SingleChildScrollView garante que a tela role quando o teclado virtual abrir
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Junte-se à nossa comunidade!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Campo de Nome Completo
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words, // Inicia cada palavra com Maiúscula
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de E-mail
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress, // Otimiza o teclado para digitação de e-mail
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de Senha
            TextField(
              controller: _senhaController,
              obscureText: true, // Oculta a senha
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de Confirmação de Senha
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 32),

            // Botão de Cadastro
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Feedback visual de sucesso (UX) usando Snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta criada com sucesso! Bem-vindo ao comunityLer.'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Volta para a tela anterior (Login) após o cadastro
                Navigator.pop(context);
              },
              child: const Text('CADASTRAR', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}