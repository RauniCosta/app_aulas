class NomeInvalidoException implements Exception {

// Mensagem de erro personalizada
  @override
  String toString() {
    return 'Nome inválido! O nome do aluno não pode ser vazio.';
  }
}

