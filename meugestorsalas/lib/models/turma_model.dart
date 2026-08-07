class Turma {
  final String nome;
  final String modalidade; // Ex: "Ensino Médio" ou "Modular"
  final String turno;      // Ex: "Manhã", "Tarde", "Noite"
  final Map<String, List<String>> aulas; // Ex: {"Segunda": ["C1", "-"], "Terça": [...]}


  Turma({
    required this.nome,
    required this.modalidade,
    required this.turno,
    required this.aulas,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'modalidade': modalidade,
    'turno': turno,
    'aulas': aulas, // Salva o dicionário completo
  };

 factory Turma.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> mapaAulas = {};
    
    // Lê o formato novo (Dias da Semana)
    if (json['aulas'] != null) {
      (json['aulas'] as Map<String, dynamic>).forEach((dia, lista) {
        mapaAulas[dia] = List<String>.from(lista);
      });
    } 
    // Compatibilidade com o banco antigo (joga tudo para a Quarta-feira)
    else if (json['alocacoes'] != null) {
      mapaAulas['Quarta'] = List<String>.from(json['alocacoes']);
      // Preenche os outros dias vazios
      for (var d in ['Segunda', 'Terça', 'Quinta', 'Sexta']) {
        mapaAulas[d] = List.filled(7, "-"); 
      }
    }

    return Turma(
      nome: json['nome'],
      modalidade: json['modalidade'] ?? 'Ensino Médio',
      turno: json['turno'] ?? 'Manhã',
      aulas: mapaAulas,
    );
  }
}