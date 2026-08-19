// Ficheiro: lib/data/models/turma_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TurmaModel {
  final String id;
  final String cursoId;
  final String nome; // Ex: "Turma A", "Turma 2026/1"
  final DateTime dataInicio;
  final DateTime dataFim;
  final String periodo; // Ex: "Manhã", "Tarde", "Noite", "Integral"

  TurmaModel({
    required this.id,
    required this.cursoId,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    required this.periodo,
  });

  factory TurmaModel.fromMap(Map<String, dynamic> map, String id) {
    return TurmaModel(
      id: id,
      cursoId: map['cursoId'] ?? '',
      nome: map['nome'] ?? '',
      dataInicio: map['dataInicio'] != null
          ? (map['dataInicio'] as Timestamp).toDate()
          : DateTime.now(),
      dataFim: map['dataFim'] != null
          ? (map['dataFim'] as Timestamp).toDate()
          : DateTime.now(),
      periodo: map['periodo'] ?? 'Manhã',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cursoId': cursoId,
      'nome': nome,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'periodo': periodo,
    };
  }

  // Auxiliar para formatar datas no padrão brasileiro
  String get periodoFormatado {
    final ini = "${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year}";
    final fim = "${dataFim.day.toString().padLeft(2, '0')}/${dataFim.month.toString().padLeft(2, '0')}/${dataFim.year}";
    return "$nome ($periodo) - $ini a $fim";
  }
}