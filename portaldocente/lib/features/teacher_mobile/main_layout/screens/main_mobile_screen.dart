// Ficheiro: lib/features/teacher_mobile/main_layout/screens/main_mobile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Importa as nossas telas criadas anteriormente
import '../../dashboard/screens/dashboard_screen.dart';
import '../../agenda/screens/agenda_screen.dart';
import '../../scale_overview/screens/cursos_docentes_screen.dart';
import '../../perfil/screens/perfil_screen.dart'; // 1. NOVO IMPORT DA TELA DE PERFIL

// 1. Provider que guarda o índice da aba selecionada (começa no 0)
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainMobileScreen extends ConsumerWidget {
  const MainMobileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutamos qual é o índice atual
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // 2. Lista de telas correspondentes a cada aba
    final List<Widget> telas = [
      const DashboardScreen(), // Índice 0
      const AgendaScreen(), // Índice 1
      const CursosDocentesScreen(), // Índice 2
      const PerfilScreen(), // Índice 3: AGORA COM O PERFIL REAL E LOGOUT!
    ];

    return Scaffold(
      // O IndexedStack mantém o estado de cada tela ao trocar de aba
      body: IndexedStack(index: currentIndex, children: telas),

      // 3. O Menu Inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Atualiza o provider, trocando a tela instantaneamente
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Cursos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
