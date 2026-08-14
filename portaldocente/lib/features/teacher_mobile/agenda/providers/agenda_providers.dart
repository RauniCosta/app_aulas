// Ficheiro: lib/features/teacher_mobile/agenda/providers/agenda_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/escala_model.dart';

// Provider que simula a agenda de um professor específico.
// Agora atualizado para a nossa nova estrutura de Blocos e Turnos!
final agendaDoDiaProvider = Provider<List<EscalaModel>>((ref) {
  return [
    EscalaModel(
      id: 'e1',
      idCurso: 'Desenvolvimento de Sistemas', 
      nomeUnidadeCurricular: 'Modelagem de Sistemas',
      idDocentes: ['Ricardo Silva', 'Ana Souza'], // Dois professores!
      diaDaSemana: 'Segunda-feira', // NOVO: Substituiu o dataHoraInicio
      blocoTurno: 'Manhã (08:00 - 12:30)', // NOVO: Substituiu o dataHoraFim
      sala: 'Sala 301, Bloco C',
      confirmada: true,
    ),
    EscalaModel(
      id: 'e2',
      idCurso: 'Técnico em Informática',
      nomeUnidadeCurricular: 'Lógica de Programação',
      idDocentes: ['Ricardo Silva'],
      diaDaSemana: 'Segunda-feira',
      blocoTurno: 'Tarde (13:30 - 17:30)',
      sala: 'Lab 2, Bloco A',
      confirmada: true,
    ),
  ];
});