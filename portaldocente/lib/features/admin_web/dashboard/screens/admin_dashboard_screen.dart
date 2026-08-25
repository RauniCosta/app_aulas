// Ficheiro: lib/features/admin_web/dashboard/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/escala_model.dart';
import '../../../../data/repositories/escala_repository.dart';
import '../../../../data/models/curso_model.dart';
import '../../manage_courses/providers/curso_providers.dart';

// Provider que busca a grelha completa de aulas
final matrizEscalasProvider = FutureProvider.autoDispose<List<EscalaModel>>((
  ref,
) async {
  final repo = EscalaRepository();
  return await repo.getAllEscalas();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  // Lista de dias da semana para o cabeçalho e cruzamento da matriz
  final List<String> _diasDaSemana = const [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  // Função auxiliar para obter o nome do curso a partir do ID
  String _obterNomeCurso(String idCurso, List<CursoModel> cursos) {
    for (final curso in cursos) {
      if (curso.id == idCurso) {
        return curso.nome;
      }
    }
    return idCurso; // Retorna o ID caso o curso não seja encontrado
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escalasAsync = ref.watch(matrizEscalasProvider);
    final cursosAsync = ref.watch(cursosListProvider);

    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral da Matriz',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Abas para alternar os turnos
            const TabBar(
              labelColor: Color(0xFF2E8B57),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF2E8B57),
              tabs: [
                Tab(text: 'Manhã (08:00 - 12:30)'),
                Tab(text: 'Tarde (13:30 - 17:30)'),
                Tab(text: 'Noite (18:30 - 22:30)'),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: cursosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Erro ao carregar cursos: $err')),
                data: (listaCursos) {
                  return escalasAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Center(child: Text('Erro ao carregar escalas: $err')),
                    data: (listaEscalas) {
                      return TabBarView(
                        children: [
                          _buildMatrizTurno(
                            listaEscalas,
                            'Manhã (08:00 - 12:30)',
                            listaCursos,
                          ),
                          _buildMatrizTurno(
                            listaEscalas,
                            'Tarde (13:30 - 17:30)',
                            listaCursos,
                          ),
                          _buildMatrizTurno(
                            listaEscalas,
                            'Noite (18:30 - 22:30)',
                            listaCursos,
                          ),
                        ],
                      );
                    },
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
  Widget _buildMatrizTurno(
    List<EscalaModel> todasEscalas,
    String turno,
    List<CursoModel> listaCursos,
  ) {
    // 1. Filtra as escalas apenas deste turno
    final escalasDoTurno = todasEscalas
        .where((e) => e.blocoTurno == turno)
        .toList();

    if (escalasDoTurno.isEmpty) {
      return const Center(child: Text('Nenhuma aula alocada para este turno.'));
    }

    // 2. Descobre quais cursos têm aula neste turno
    final cursosNoTurno = escalasDoTurno.map((e) => e.idCurso).toSet().toList();
    cursosNoTurno.sort();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(
          0xFFF0FFF0,
        ), // Verde Menta (Fundo reage ao mouse)
        onTap: () {
          // Ao adicionar um onTap vazio ou funcional, o cursor vira uma "Mãozinha" (Pointer)
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(180), // Coluna do Curso
                    1: FixedColumnWidth(150), // Segunda
                    2: FixedColumnWidth(150), // Terça
                    3: FixedColumnWidth(150), // Quarta
                    4: FixedColumnWidth(150), // Quinta
                    5: FixedColumnWidth(150), // Sexta
                    6: FixedColumnWidth(150), // Sábado
                  },
                  children: [
                    // CABEÇALHO DA TABELA
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Cursos',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ..._diasDaSemana.map(
                          (dia) => Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              dia,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // LINHAS DOS CURSOS
                    ...cursosNoTurno.map((idCurso) {
                      final nomeDoCurso = _obterNomeCurso(idCurso, listaCursos);

                      return TableRow(
                        children: [
                          // Primeira Célula: Nome do Curso
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              nomeDoCurso,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E8B57),
                              ),
                            ),
                          ),

                          // Demais Células: Procurar se há aula deste curso neste dia
                          ..._diasDaSemana.map((dia) {
                            final aulasFiltradas = escalasDoTurno
                                .where(
                                  (e) =>
                                      e.idCurso == idCurso &&
                                      e.diaDaSemana == dia,
                                )
                                .toList();

                            if (aulasFiltradas.isEmpty) {
                              return const SizedBox(height: 60); // Célula Vazia
                            }

                            final aula = aulasFiltradas.first;

                            // Desenha o cartão da disciplina e professores
                            return Container(
                              height: 80,
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    aula.nomeUnidadeCurricular,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    aula.idDocentes.isEmpty
                                        ? 'Sem professor'
                                        : aula.idDocentes.join(', '),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
        ),
      ),
    );
  }
}
