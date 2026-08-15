// Ficheiro: lib/features/teacher_mobile/agenda/screens/agenda_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agenda_providers.dart';
import '../../../../data/models/escala_model.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuta o nosso StreamProvider Mágico que vai ao Firebase
    final agendaAsyncValue = ref.watch(agendaDoProfessorProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E5BB2),
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
        
        // 2. O body reage ao estado da internet
        body: agendaAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1E5BB2))),
          error: (erro, stack) => Center(child: Text('Ocorreu um erro: $erro', style: const TextStyle(color: Colors.red))),
          data: (escalas) {
            return TabBarView(
              children: [
                // ATENÇÃO AQUI: Passamos context e ref para dentro da função!
                _buildTimelineDiaria(context, ref, escalas),
                const Center(child: Text('Visão Semanal em construção 🚧')),
                const Center(child: Text('Visão Mensal em construção 🚧')),
              ],
            );
          },
        ),
      ),
    );
  }

  // 3. Constrói a lista com suporte a "Arrastar para Atualizar" (RefreshIndicator)
  Widget _buildTimelineDiaria(BuildContext context, WidgetRef ref, List<EscalaModel> escalas) {
    // Se a lista estiver vazia
    if (escalas.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          // Força a recarregar o Provider
          ref.invalidate(agendaDoProfessorProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), // Garante que consegue arrastar mesmo vazio
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
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

    // Se tiver dados
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(agendaDoProfessorProvider);
      },
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

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- LINHA DO TEMPO (ESQUERDA) ---
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

              // --- CARTÃO DA AULA (DIREITA) ---
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
                      left: BorderSide(
                        color: isFirst ? Colors.orange : const Color(0xFF1E5BB2), 
                        width: 6,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              escala.idCurso,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(escala.diaDaSemana, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${escala.nomeUnidadeCurricular}\n${escala.sala}',
                        style: TextStyle(color: Colors.grey[700], height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          nomeTurno,
                          style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}