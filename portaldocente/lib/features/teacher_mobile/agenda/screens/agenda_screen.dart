// Ficheiro: lib/features/teacher_mobile/agenda/screens/agenda_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agenda_providers.dart';
import '../../../../data/models/escala_model.dart';

// Imports para traduzir os Cursos
import '../../../../data/models/curso_model.dart';
import '../../../admin_web/manage_courses/providers/curso_providers.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuta o StreamProvider
    final agendaAsyncValue = ref.watch(agendaDoProfessorProvider);

    // 2. Lê a lista de cursos de forma segura
    final cursosAsync = ref.watch(cursosListProvider);
    final listaCursos = cursosAsync.maybeWhen(
      data: (cursos) => cursos,
      orElse: () => <CursoModel>[],
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E8B57),
          elevation: 0,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minha Agenda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Aulas Alocadas', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
          bottom: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.2),
            ),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Dia'),
              Tab(text: 'Semana'),
              Tab(text: 'Mês'),
            ],
          ),
        ),
        
        body: agendaAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2E8B57))),
          error: (erro, stack) => Center(child: Text('Ocorreu um erro: $erro', style: const TextStyle(color: Colors.red))),
          data: (escalas) {
            return TabBarView(
              children: [
                _buildTimelineDiaria(context, ref, escalas, listaCursos),
                _buildVisaoSemanal(context, ref, escalas, listaCursos), // NOVO
                _buildVisaoMensal(context, escalas, listaCursos),       // NOVO
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 1. ABA DIA (TIMELINE) ---
  Widget _buildTimelineDiaria(BuildContext context, WidgetRef ref, List<EscalaModel> escalas, List<CursoModel> listaCursos) {
    String obterNomeCurso(String idCurso) {
      for (final curso in listaCursos) {
        if (curso.id == idCurso) return curso.nome;
      }
      return idCurso; 
    }

    if (escalas.isEmpty) {
      return _buildEmptyState(ref);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(agendaDoProfessorProvider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: escalas.length,
        itemBuilder: (context, index) {
          final escala = escalas[index];
          final bool isFirst = index == 0;
          
          String horaInicio = "00:00";
          String horaFim = "00:00";
          String nomeTurno = "Turno";
          
          try {
            nomeTurno = escala.blocoTurno.split(' ')[0]; 
            final partes = escala.blocoTurno.split('(')[1].replaceAll(')', '').split(' - ');
            horaInicio = partes[0];
            horaFim = partes[1];
          } catch (e) {
            horaInicio = "Início";
            horaFim = "Fim";
          }

          final nomeDoCurso = obterNomeCurso(escala.idCurso);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(horaInicio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    width: 2,
                    height: 120,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  Text(horaFim, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                    border: Border(
                      left: BorderSide(color: isFirst ? Color(0xFFFFC107) : const Color(0xFF2E8B57), width: 6),
                    ),
                  ),
                  child: _buildCardContent(escala, nomeDoCurso, nomeTurno),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 2. ABA SEMANA (AGRUPADA POR DIA) ---
  Widget _buildVisaoSemanal(BuildContext context, WidgetRef ref, List<EscalaModel> escalas, List<CursoModel> listaCursos) {
    if (escalas.isEmpty) return _buildEmptyState(ref);

    final diasDaSemana = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];

    String obterNomeCurso(String idCurso) {
      for (final curso in listaCursos) {
        if (curso.id == idCurso) return curso.nome;
      }
      return idCurso; 
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(agendaDoProfessorProvider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: diasDaSemana.length,
        itemBuilder: (context, index) {
          final dia = diasDaSemana[index];
          final aulasDoDia = escalas.where((e) => e.diaDaSemana == dia).toList();

          if (aulasDoDia.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), fontSize: 16)),
              ),
              ...aulasDoDia.map((escala) {
                final nomeDoCurso = obterNomeCurso(escala.idCurso);
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
                  ),
                  child: _buildCardContent(escala, nomeDoCurso, escala.blocoTurno),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  // --- 3. ABA MÊS (RESUMO MENSAL) ---
  Widget _buildVisaoMensal(BuildContext context, List<EscalaModel> escalas, List<CursoModel> listaCursos) {
    if (escalas.isEmpty) {
      return const Center(child: Text('Nenhuma aula para o mês atual.'));
    }

    final totalAulasSemanais = escalas.length;
    // Estimativa simples de aulas no mês (4 semanas)
    final totalAulasMes = totalAulasSemanais * 4; 
    final ucsUnicas = escalas.map((e) => e.nomeUnidadeCurricular).toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do Mês Atual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Aulas no Mês', '$totalAulasMes', Icons.event_note, Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildMetricCard('UCs Ativas', '${ucsUnicas.length}', Icons.book, Color(0xFFFFC107)),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text('Suas Disciplinas neste Mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),

          ...ucsUnicas.map((uc) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.class_, color: Color(0xFF2E8B57), size: 20),
                ),
                title: Text(uc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Ativa neste período', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildEmptyState(WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(agendaDoProfessorProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 15),
                Text(
                  'Sem aulas alocadas para si.\nArraste para baixo para atualizar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(EscalaModel escala, String nomeDoCurso, String nomeTurno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$nomeDoCurso - ${escala.turma}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(escala.diaDaSemana, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text('${escala.nomeUnidadeCurricular}\n${escala.sala}', style: TextStyle(color: Colors.grey[700], height: 1.4)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(nomeTurno, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: escala.idDocentes.map<Widget>((nome) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: Text(nome.isNotEmpty ? nome[0] : '?', style: const TextStyle(fontSize: 10, color: Colors.black)),
                ),
                const SizedBox(width: 5),
                Text(nome, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}