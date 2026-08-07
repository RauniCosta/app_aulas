import 'Pessoa.dart';

class Pessoajuridica extends Pessoa {
  String _cnpj = "";

  // Getter and Setter for cnpj
  String get cnpj => _cnpj;
  set cnpj(String cnpj) => _cnpj = cnpj;

  Pessoajuridica(String nome, String sobrenome, int idade, String cnpj)
      : super(nome, sobrenome, idade) {
    _cnpj = cnpj;
  }

  @override
  String toString() {
    return {
      "Nome": super.getNome(),
      "sobrenome": super.getSobrenome(),
      "idade": super.getIdade(),
      "cnpj": _cnpj
    }.toString();
  }

 
}