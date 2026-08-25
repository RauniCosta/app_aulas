// Ficheiro: lib/data/models/docente_model.dart

class DocenteModel {
  final String id;
  final String nome;
  final String sigla;
  final String titulo;
  final String email;
  final String telefone;
  final List<String> especialidades;
  final List<String> diasEscala; // NOVO: Guarda os dias que o prof trabalha
  final String fotoUrl;

  DocenteModel({
    required this.id,
    required this.nome,
    required this.sigla,
    this.titulo = 'Prof.',
    required this.email,
    this.telefone = '',
    this.especialidades = const [],
    this.diasEscala = const [], // NOVO
    this.fotoUrl = '',
  });

  factory DocenteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DocenteModel(
      id: documentId,
      nome: map['nome'] ?? '',
      sigla: map['sigla']?? '',
      titulo: map['titulo'] ?? 'Prof.',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      especialidades: List<String>.from(map['especialidades'] ?? []),
      diasEscala: List<String>.from(map['diasEscala'] ?? []), // NOVO
      fotoUrl: map['fotoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'sigla':sigla,
      'titulo': titulo,
      'email': email,
      'telefone': telefone,
      'especialidades': especialidades,
      'diasEscala': diasEscala, // NOVO
      'fotoUrl': fotoUrl,
    };
  }

  /// Método útil para clonar o objeto alterando apenas alguns campos (útil para edição)
  DocenteModel copyWith({
    String? id,
    String? nome,
    String? sigla,
    String? titulo,
    String? email,
    String? telefone,
    List<String>? especialidades,
    List<String>? diasEscala, 
    String? fotoUrl,
  }) {
    return DocenteModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sigla: sigla ?? this.sigla,
      titulo: titulo ?? this.titulo,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      especialidades: especialidades ?? this.especialidades,
      diasEscala: diasEscala ?? this.diasEscala,  
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
  
