// Ficheiro: lib/core/routing/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portaldocente/features/admin_web/main_layout/screens/main_web_screen.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/teacher_mobile/main_layout/screens/main_mobile_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o estado do login
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (user) {
        // Se não houver utilizador logado, mostra a tela de Login
        if (user == null) {
          return const LoginScreen();
        }

        // Se houver utilizador logado, vamos descobrir qual é o role dele!
        return RoleGate(uid: user.uid);
      },
    );
  }
}

// Widget auxiliar que busca a função (role) do utilizador
class RoleGate extends ConsumerWidget {
  final String uid;
  const RoleGate({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsyncValue = ref.watch(userRoleProvider(uid));

    return roleAsyncValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Erro ao buscar perfil: $e'))),
      data: (role) {
        // A MÁGICA ACONTECE AQUI! O redirecionamento baseado no perfil.
        if (role == 'admin') {
          return const MainWebScreen(); // Nosso Painel Web
        } else {
          return const MainMobileScreen(); // Nosso App Mobile
        }
      },
    );
  }
}