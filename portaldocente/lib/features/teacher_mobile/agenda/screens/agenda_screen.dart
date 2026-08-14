// Ficheiro: lib/features/teacher_mobile/agenda/screens/agenda_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agenda_providers.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escutamos as escalas do nosso Provider (agora com a nova estrutura)
    final escalasDoDia = ref.watch(agendaDoDiaProvider);

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
              Text('Esta Semana', style: TextStyle(fontSize: 14, color: Colors.white70)),
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
        body: TabBarView(
          children: [
            _buildTimelineDiaria(escalasDoDia),
            const Center(child: Text('Visão Semanal em construção')),
            const Center(child: Text('Visão Mensal em construção')),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineDiaria(List<dynamic> escalas) {
    if (escalas.isEmpty) {
      return const Center(child: Text('Sem aulas agendadas para hoje.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: escalas.length,
      itemBuilder: (context, index) {
        final escala = escalas[index];
        final bool isFirst = index == 0;
        
        // 2. Extrair as horas do texto "Manhã (08:00 - 12:30)" para a UI ficar bonita
        String horaInicio = "00:00";
        String horaFim = "00:00";
        String nomeTurno = "Turno";
        
        try {
          nomeTurno = escala.blocoTurno.split(' ')[0]; // Pega a primeira palavra (Manhã/Tarde/Noite)
          final partes = escala.blocoTurno.split('(')[1].replaceAll(')', '').split(' - ');
          horaInicio = partes[0];
          horaFim = partes[1];
        } catch (e) {
          // Segurança caso o formato do texto venha diferente
          horaInicio = "Início";
          horaFim = "Fim";
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COLUNA DA ESQUERDA (HORAS E LINHA DO TEMPO) ---
            Column(
              children: [
                Text(horaInicio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  width: 2,
                  height: 100, // Altura da linha
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                Text(horaFim, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(width: 20),

            // --- COLUNA DA DIREITA (CARTÃO DA AULA) ---
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
                        if (escala.confirmada)
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text(' Confirmada', style: TextStyle(color: Colors.green, fontSize: 12)),
                            ],
                          )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${escala.nomeUnidadeCurricular}\n${escala.sala}',
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    
                    // Selo identificador do Turno
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
                    
                    // Lista de Professores Alocados (Adaptado para Wrap para evitar transbordar a tela)
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
                              child: Text(nome[0], style: const TextStyle(fontSize: 10, color: Colors.black)),
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
    );
  }
}