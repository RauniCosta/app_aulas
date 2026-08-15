// Ficheiro: lib/data/models/unidade_curricular_model.dart

class UnidadeCurricularModel {
  final String id;
  final String cursoId; // Faz a ligação com o CursoModel
  final String nome; // Ex: Lógica de Programação, Edição de Vídeo com IA
  final int cargaHoraria; // Ex: 60
  final String moduloOuSemestre; // Ex: 1 (Primeiro módulo)

  UnidadeCurricularModel({
    required this.id,
    required this.cursoId,
    required this.nome,
    required this.cargaHoraria,
    required this.moduloOuSemestre,
  });

  factory UnidadeCurricularModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UnidadeCurricularModel(
      id: documentId,
      cursoId: map['cursoId'] ?? '',
      nome: map['nome'] ?? '',
      cargaHoraria: map['cargaHoraria']?.toInt() ?? 0,
      moduloOuSemestre: map['moduloOuSemestre']?.toString() ?? 'Modulo 1', // Converte com segurança
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cursoId': cursoId,
      'nome': nome,
      'cargaHoraria': cargaHoraria,
      'moduloOuSemestre': moduloOuSemestre,
    };
  }
}