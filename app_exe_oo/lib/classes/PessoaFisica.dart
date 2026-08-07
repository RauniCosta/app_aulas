import 'Pessoa.dart';

class PessoaFisica extends Pessoa {
  String _cpf = "";

  void setCpf(String cpf) {
    _cpf = cpf;
  }

  String getCpf() {
    return _cpf;
  }

  PessoaFisica(String nome, String sobrenome, int idade, String cpf) 
    : super(nome, sobrenome, idade) {
    _cpf = cpf;
  }

  @override
  String toString() {
    return {
      "Nome": super.getNome(),
      "sobrenome": super.getSobrenome(),
      "idade": super.getIdade(),
      "cpf": _cpf
    }.toString();
  }
}