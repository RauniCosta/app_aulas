// Classe Aluno

class Aluno {

  String _nome = "";
  List<double> _notas = [];

// Construtor
  Aluno(String nome) {
    _nome = nome;
  }

// Getters e Setters
  void setNome(String nome) {
    _nome = nome;
  }
  
  String getNome() {
    return _nome;
  }

  List<double> getNotas() {
    return _notas;
  }
  void adicionarNota(double nota) {
    _notas.add(nota);
  }


// Métodos
  double calcularMedia() {
    double soma = 0;
    for (double nota in _notas) {
      soma += nota;
    }
    var media = soma / _notas.length;

    return media.isNaN ? 0 : media;

  }

  bool aprovado(double media) {
    return media >= 7.0;
  }

  
}
