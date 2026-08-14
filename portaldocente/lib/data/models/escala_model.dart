// Ficheiro: lib/data/models/escala_model.dart

class EscalaModel {
  final String id;
  final String idCurso; 
  final String nomeUnidadeCurricular; 
  final List<String> idDocentes; // Lista de IDs/Nomes dos professores
  final String diaDaSemana; // Ex: "Segunda-feira", "Terça-feira"
  final String blocoTurno; // Ex: "Manhã (08:00 - 12:30)", "Tarde", "Noite"
  final String sala; 
  final bool confirmada;

  EscalaModel({
    required this.id,
    required this.idCurso,
    required this.nomeUnidadeCurricular,
    required this.idDocentes,
    required this.diaDaSemana,
    required this.blocoTurno,
    required this.sala,
    this.confirmada = true,
  });

  factory EscalaModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EscalaModel(
      id: documentId,
      idCurso: map['idCurso'] ?? '',
      nomeUnidadeCurricular: map['nomeUnidadeCurricular'] ?? '',
      idDocentes: List<String>.from(map['idDocentes'] ?? []),
      diaDaSemana: map['diaDaSemana'] ?? 'Segunda-feira',
      blocoTurno: map['blocoTurno'] ?? 'Manhã',
      sala: map['sala'] ?? '',
      confirmada: map['confirmada'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCurso': idCurso,
      'nomeUnidadeCurricular': nomeUnidadeCurricular,
      'idDocentes': idDocentes,
      'diaDaSemana': diaDaSemana,
      'blocoTurno': blocoTurno,
      'sala': sala,
      'confirmada': confirmada,
    };
  }
}