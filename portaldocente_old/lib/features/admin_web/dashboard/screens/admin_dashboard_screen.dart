// Ficheiro: lib/features/admin_web/dashboard/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/escala_model.dart';
import '../../../../data/repositories/escala_repository.dart';

// Provider que busca a grelha completa de aulas
final matrizEscalasProvider = FutureProvider.autoDispose<List<EscalaModel>>((ref) async {
  final repo = EscalaRepository();
  return await repo.getAllEscalas();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  final List<String> _diasDaSemana = const [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 
    'Quinta-feira', 'Sexta-feira', 'Sábado'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escalasAsync = ref.watch(matrizEscalasProvider);

    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visão Geral da Matriz', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('Acompanhe a alocação de todos os cursos por turno', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // ABAS DOS TURNOS
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: TabBar(
                labelColor: const Color(0xFF1E5BB2),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1E5BB2),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: '☀️ MANHÃ (08:00 - 12:30)'),
                  Tab(text: '🌤️ TARDE (13:30 - 17:30)'),
                  Tab(text: '🌙 NOITE (18:30 - 22:30)'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CONTEÚDO DAS ABAS (AS TABELAS)
            Expanded(
              child: escalasAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Erro ao carregar matriz: $e')),
                data: (todasEscalas) {
                  return TabBarView(
                    children: [
                      _buildMatrizTurno(todasEscalas, 'Manhã (08:00 - 12:30)'),
                      _buildMatrizTurno(todasEscalas, 'Tarde (13:30 - 17:30)'),
                      _buildMatrizTurno(todasEscalas, 'Noite (18:30 - 22:30)'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constrói a tabela para um turno específico
  Widget _buildMatrizTurno(List<EscalaModel> todasEscalas, String turno) {
    // 1. Filtra as escalas apenas deste turno
    final escalasDoTurno = todasEscalas.where((e) => e.blocoTurno == turno).toList();

    if (escalasDoTurno.isEmpty) {
      return const Center(child: Text('Nenhuma aula alocada para este turno.'));
    }

    // 2. Descobre quais cursos têm aula neste turno (para criar as linhas)
    final cursosNoTurno = escalasDoTurno.map((e) => e.idCurso).toSet().toList();
    cursosNoTurno.sort(); // Organiza por ordem alfabética

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 1, borderRadius: BorderRadius.circular(5)),
              columnWidths: const {
                0: FixedColumnWidth(180), // Coluna do Curso (mais larga)
                1: FixedColumnWidth(150), // Segunda
                2: FixedColumnWidth(150), // Terça
                3: FixedColumnWidth(150), // Quarta
                4: FixedColumnWidth(150), // Quinta
                5: FixedColumnWidth(150), // Sexta
                6: FixedColumnWidth(150), // Sábado
              },
              children: [
                // CABAÇALHO DA TABELA
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    const Padding(padding: EdgeInsets.all(12), child: Text('Cursos', style: TextStyle(fontWeight: FontWeight.bold))),
                    ..._diasDaSemana.map((dia) => Padding(padding: const EdgeInsets.all(12), child: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                  ],
                ),
                
                // LINHAS DOS CURSOS
                ...cursosNoTurno.map((curso) {
                  return TableRow(
                    children: [
                      // Primeira Célula: Nome do Curso
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(curso, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E5BB2))),
                      ),
                      // Demais Células: Procurar se há aula deste curso neste dia
                      ..._diasDaSemana.map((dia) {
                        // Procura a aula exata que cruza este Curso + Turno + Dia
                        final aula = escalasDoTurno.where((e) => e.idCurso == curso && e.diaDaSemana == dia).firstOrNull;

                        if (aula == null) {
                          return const SizedBox(height: 60); // Célula Vazia
                        }

                        // Se houver aula, desenha o cartão da disciplina e professores
                        return Container(
                          height: 80,
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(aula.nomeUnidadeCurricular, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(aula.idDocentes.join(', '), style: TextStyle(fontSize: 10, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}