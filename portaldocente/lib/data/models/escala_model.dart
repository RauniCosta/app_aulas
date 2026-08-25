// Ficheiro: lib/data/models/escala_model.dart

class EscalaModel {
  final String id;
  final String idCurso;
  final String turma;
  final String nomeUnidadeCurricular;
  final List<String> idDocentes; // Lista correta de docentes
  final String diaDaSemana;
  final String blocoTurno;
  final String sala;
  final bool confirmada;

  EscalaModel({
    required this.id,
    required this.idCurso,
    this.turma = 'Turma A', 
    required this.nomeUnidadeCurricular,
    required this.idDocentes,
    required this.diaDaSemana,
    required this.blocoTurno,
    this.sala = 'A Definir',
    this.confirmada = false,
    // APAGAR idDocente, data, horaInicio, horaFim daqui
  });

  factory EscalaModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EscalaModel(
      id: documentId,
      idCurso: map['idCurso'] ?? '',
      turma: map['turma'] ?? 'Turma A',
      nomeUnidadeCurricular: map['nomeUnidadeCurricular'] ?? '',
      idDocentes: List<String>.from(map['idDocentes'] ?? []),
      diaDaSemana: map['diaDaSemana'] ?? '',
      blocoTurno: map['blocoTurno'] ?? '',
      sala: map['sala'] ?? 'A Definir',
      confirmada: map['confirmada'] ?? false,
      // APAGAR data, horaInicio, horaFim daqui também
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCurso': idCurso,
      'turma': turma,
      'nomeUnidadeCurricular': nomeUnidadeCurricular,
      'idDocentes': idDocentes,
      'diaDaSemana': diaDaSemana,
      'blocoTurno': blocoTurno,
      'sala': sala,
      'confirmada': confirmada,
    };
  }
}
