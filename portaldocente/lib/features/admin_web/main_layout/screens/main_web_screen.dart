// Ficheiro: lib/features/admin_web/main_layout/screens/main_web_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para o logout
import 'package:flutter_riverpod/legacy.dart';


import '../../manage_teachers/screens/manage_teachers_screen.dart';
import '../../manage_courses/screens/manage_courses_screen.dart';
import '../../scale_builder/screens/scale_builder_screen.dart';

// 1. Provider que controla qual aba está selecionada
final adminMenuIndexProvider = StateProvider<int>((ref) => 0);

class MainWebScreen extends ConsumerWidget {
  const MainWebScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminMenuIndexProvider);

    // 2. Lista de Telas do Painel
    final List<Widget> telas = [
      const ManageTeachersScreen(), // Índice 0
      const ManageCoursesScreen(),  // Índice 1
      const ScaleBuilderScreen(),   // Índice 2
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // --- MENU LATERAL ÚNICO E GLOBAL ---
          Container(
            width: 250,
            color: const Color(0xFF1E5BB2),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text('EducaLink Admin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                // Botões de Navegação
                _buildMenuItem(ref, Icons.people, 'Docentes', 0, currentIndex),
                _buildMenuItem(ref, Icons.menu_book, 'Cursos e UCs', 1, currentIndex),
                _buildMenuItem(ref, Icons.calendar_month, 'Montar Escala', 2, currentIndex),
                
                const Spacer(),
                
                // Botão de Logout Movido para cá
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.white70),
                  title: const Text('Terminar Sessão', style: TextStyle(color: Colors.white70)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // --- CONTEÚDO DINÂMICO (Troca de tela aqui) ---
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: telas,
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os botões do menu
  Widget _buildMenuItem(WidgetRef ref, IconData icon, String title, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    return Container(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(title, style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70, 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )),
        onTap: () {
          // Atualiza o índice e troca a tela instantaneamente!
          ref.read(adminMenuIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}