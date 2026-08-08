// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart'; // Importa o modelo que criamos antes

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função assíncrona para iniciar sessão (Login)
  Future<String?> loginUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      // Tenta iniciar sessão no Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );
      
      return null; // Retorna nulo se o login for bem-sucedido

    } on FirebaseAuthException catch (e) {
      // Tratamento de erros comuns de login
      // Nota: O Firebase mais recente usa 'invalid-credential' por segurança, 
      // para não revelar se o erro foi no e-mail ou na palavra-passe.
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'E-mail ou palavra-passe incorretos.';
      } else if (e.code == 'invalid-email') {
        return 'O formato do e-mail é inválido.';
      }
      return 'Erro de autenticação: ${e.message}';
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
  
  // Função assíncrona para registrar o usuário
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      // 1. Cria o usuário no Firebase Auth (O "Cofre" com criptografia)
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      // 2. Cria o objeto do nosso Modelo
      UsuarioModel novoUsuario = UsuarioModel(
        uid: credencial.user!.uid,
        nome: nome.trim(),
        email: email.trim(),
        // multaAcumulada já vai como 0.0 por padrão no modelo
      );

      // 3. Salva os dados não sensíveis no Firestore (Banco de Dados)
      await _firestore
          .collection('usuarios')
          .doc(novoUsuario.uid)
          .set(novoUsuario.toMap());

      return null; // Retorna nulo se deu tudo certo (nenhum erro)

    } on FirebaseAuthException catch (e) {
      // Tratamento de exceções específico do Firebase
      if (e.code == 'weak-password') {
        return 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        return 'Já existe uma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        return 'O e-mail fornecido é inválido.';
      }
      return 'Erro de autenticação: ${e.message}';
    } catch (e) {
      // Captura qualquer outro erro genérico (ex: falha de internet)
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}