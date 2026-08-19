// Ficheiro: lib/features/teacher_mobile/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../agenda/providers/agenda_providers.dart';
import '../../perfil/screens/perfil_screen.dart'; // Para dados do professor
import '../../../../data/models/escala_model.dart';
import '../../main_layout/screens/main_mobile_screen.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // --- HEADER COM SAUDAÇÃO PERSONALIZADA ---
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E5BB2),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E5BB2), Color(0xFF14428D)],
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

          // --- CONTEÚDO PRINCIPAL ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. BANNER "PRÓXIMA AULA / AULA ATUAL" ---
                  const Text('Sua Próxima Aula', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                child: const Icon(Icons.event_available, color: Color(0xFF1E5BB2), size: 30),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nenhuma aula agendada agora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('Aproveite seu tempo livre ou consulte a agenda completa.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Pega a primeira aula da lista como a próxima/atual
                      final proximaAula = escalas.first;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E5BB2), Color(0xFF2A6FD6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF1E5BB2).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    proximaAula.diaDaSemana.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    proximaAula.sala,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              proximaAula.nomeUnidadeCurricular,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Curso: ${proximaAula.idCurso} (${proximaAula.turma})',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const Divider(color: Colors.white30, height: 25),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.white70, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  proximaAula.blocoTurno,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // --- 2. PAINEL DE MÉTRICAS RÁPIDAS ---
                  const Text('Resumo da Semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),

                  agendaAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (escalas) {
                      final totalAulas = escalas.length;
                      final totalCursos = escalas.map((e) => e.idCurso).toSet().length;

                      return Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard('Aulas Agendadas', '$totalAulas', Icons.calendar_today, Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard('Cursos Ativos', '$totalCursos', Icons.school, Colors.green),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // --- 3. ATALHOS RÁPIDOS ---
                  const Text('Acesso Rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickActionButton(
                        context: context,
                        ref: ref,
                        icon: Icons.calendar_month,
                        label: 'Ver Agenda',
                        targetIndex: 1, // Redireciona para a aba Agenda
                      ),
                      _buildQuickActionButton(
                        context: context,
                        ref: ref,
                        icon: Icons.grid_view,
                        label: 'Minhas Turmas',
                        targetIndex: 2, // Redireciona para a aba Cursos
                      ),
                      _buildQuickActionButton(
                        context: context,
                        ref: ref,
                        icon: Icons.person_outline,
                        label: 'Meu Perfil',
                        targetIndex: 3, // Redireciona para a aba Perfil
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- 4. MURAL DE COMUNICADOS / AVISOS ---
                  const Text('Mural da Coordenação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.campaign, color: Color(0xFF1E5BB2), size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lembrete: Atualização de Frequências',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Prezado docente, lembre-se de registrar a presença dos alunos ao término de cada bloco pedagógico.',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required int targetIndex,
  }) {
    return InkWell(
      onTap: () {
        // Altera a aba no BottomNavigationBar
        ref.read(bottomNavIndexProvider.notifier).state = targetIndex;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1E5BB2), size: 26),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}