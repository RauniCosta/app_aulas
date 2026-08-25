// Ficheiro: lib/features/teacher_mobile/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../agenda/providers/agenda_providers.dart';
import '../../perfil/screens/perfil_screen.dart'; 
import '../../main_layout/screens/main_mobile_screen.dart';
import '../../../../data/models/curso_model.dart';
import '../../../admin_web/manage_courses/providers/curso_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  String _obterSaudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final dadosDocenteAsync = ref.watch(dadosDocenteLogadoProvider);
    final agendaAsync = ref.watch(agendaDoProfessorProvider);
    
    final cursosAsync = ref.watch(cursosListProvider);
    final listaCursos = cursosAsync.maybeWhen(
      data: (cursos) => cursos,
      orElse: () => <CursoModel>[],
    );

    String obterNomeCurso(String idCurso) {
      for (final curso in listaCursos) {
        if (curso.id == idCurso) return curso.nome;
      }
      return idCurso;
    }

    // Capturando as cores do nosso novo tema EduSync
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = const Color(0xFFFFC107); // Amarelo Âmbar

    return Scaffold(
      // Herda automaticamente o Verde Menta do fundo (scaffoldBackgroundColor)
      backgroundColor: theme.scaffoldBackgroundColor, 
      body: CustomScrollView(
        slivers: [
          // --- HEADER COM NOVO GRADIENTE VERDE ---
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, const Color(0xFF1B4332)], // Verde Esmeralda para Verde Floresta
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_obterSaudacao()}, 👋',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        dadosDocenteAsync.when(
                          loading: () => const Text('Professor', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          error: (_, __) => Text(user?.email?.split('@')[0] ?? 'Docente', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          data: (dados) => Text(
                            dados?['nome'] ?? 'Docente',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 1. RESUMO DO DIA ---
                  agendaAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (escalas) {
                      final totalAulasHoje = escalas.length > 3 ? 3 : escalas.length; 
                      if (totalAulasHoje == 0) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Seu dia hoje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                              Text('0 de $totalAulasHoje aulas', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.0, 
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      );
                    },
                  ),

                  // --- 2. DESTAQUE: PRÓXIMA AULA ---
                  const Text('Próxima Aula', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),

                  agendaAsync.when(
                    loading: () => const Card(child: Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()))),
                    error: (err, _) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Text('Erro ao carregar aula: $err'))),
                    data: (escalas) {
                      if (escalas.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.check_circle_outline, color: primaryColor, size: 30),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Dia livre!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text('Você não tem aulas agendadas para agora.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final proximaAula = escalas.first;
                      final nomeDoCurso = obterNomeCurso(proximaAula.idCurso);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, const Color(0xFF236B42)], // Novo gradiente verde
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.schedule, color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        proximaAula.blocoTurno.split(' ').last, 
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: accentColor, // Amarelo Âmbar de Destaque
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.room, color: Colors.black87, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        proximaAula.sala,
                                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              proximaAula.nomeUnidadeCurricular,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$nomeDoCurso - ${proximaAula.turma}', 
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // --- 3. ATALHOS RÁPIDOS ---
                  const Text('O que você precisa fazer?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.checklist,
                          label: 'Frequência',
                          color: primaryColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lançamento de Frequência em breve!')));
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.menu_book,
                          label: 'Minhas Turmas',
                          color: accentColor,
                          iconColor: Colors.black87, // Contraste melhor com o amarelo
                          onTap: () {
                            ref.read(bottomNavIndexProvider.notifier).state = 2; 
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    Color? iconColor,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}