// lib/login_screen.dart
import 'package:flutter/material.dart';
import 'package:comunityler/services/auth_service.dart'; // Importamos o nosso serviço

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar o texto dos campos
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  
  // Variável de estado para mostrar o carregamento
  bool _carregando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Previne erro de ecrã ao abrir o teclado
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60), // Espaço no topo
              const Icon(Icons.account_circle, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              
              // Campo de E-mail
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de Palavra-passe (Senha)
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Palavra-passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              
              // Botão de Entrar Atualizado
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _carregando ? null : () async {
                  // Validação básica
                  if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preencha todos os campos!'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Ativa o estado de carregamento
                  setState(() { _carregando = true; });

                  // Chama o serviço de login
                  String? erro = await AuthService().loginUsuario(
                    email: _emailController.text,
                    senha: _senhaController.text,
                  );

                  // Desativa o estado de carregamento
                  setState(() { _carregando = false; });

                  if (erro == null) {
                    // Sucesso! Navega para o Menu Principal e limpa a pilha de navegação
                    Navigator.pushReplacementNamed(context, '/menu');
                  } else {
                    // Mostra o erro ao utilizador
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(erro), backgroundColor: Colors.red),
                    );
                  }
                },
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ENTRAR', style: TextStyle(fontSize: 16)),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro');
                },
                child: const Text('Não tem uma conta? Cadastre-se'),
              )
            ],
          ),
        ),
      ),
    );
  }
}