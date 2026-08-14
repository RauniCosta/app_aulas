// Ficheiro: lib/data/models/curso_model.dart

class CursoModel {
  final String id;
  final String nome; // Ex: Técnico em Informática
  final String modalidade; // Ex: Habilitação Técnica, Aperfeiçoamento Livre
  final int cargaHorariaTotal; // Ex: 1200
  final bool ativo;

  CursoModel({
    required this.id,
    required this.nome,
    required this.modalidade,
    required this.cargaHorariaTotal,
    this.ativo = true,
  });

  factory CursoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CursoModel(
      id: documentId,
      nome: map['nome'] ?? '',
      modalidade: map['modalidade'] ?? '',
      cargaHorariaTotal: map['cargaHorariaTotal']?.toInt() ?? 0,
      ativo: map['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'modalidade': modalidade,
      'cargaHorariaTotal': cargaHorariaTotal,
      'ativo': ativo,
    };
  }
}