class Tarefa {
  int? id;
  String titulo;
  String descricao;
  int concluida;

  Tarefa({
    this.id, 
    required this.titulo, 
    required this.descricao, 
    this.concluida = 0 // 0 = Falso, 1 = Verdadeiro
  });

  // Converte o objeto Tarefa para um Map
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
    };
    
    // Só envia o ID se ele não for nulo (evita erro no Autoincrement)
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }

  // Converte um Map do Banco de Dados para um objeto Tarefa
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      concluida: map['concluida'],
    );
  }
}