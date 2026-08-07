import 'package:app_exe_oo/enum/tipo_notificacao.dart';

abstract class Pessoa {
  String _nome = "";
  String _sobrenome = "";
  int _idade = 0;

  TipoNotificacao _tipoNotificacao = TipoNotificacao.nenhuma;


// Setters
  void setNome (String nome) {
    _nome = nome;
  }

  void setSobrenome (String sobrenome) {
    _sobrenome = sobrenome;
  }

  void setIdade (int idade) {
    _idade = idade;
  }

  void setTipoNotificacao (TipoNotificacao tipo) {
    _tipoNotificacao = tipo;
  }

// Getters

  TipoNotificacao getTipoNotificacao() {
    return _tipoNotificacao;
  }

  String getNome() {
    return _nome.toUpperCase();
  }
  
  String getSobrenome() {
    return _sobrenome;
  }

  int getIdade() {
    return _idade;
  } 


  String getNomeCompleto() {
    return '$_nome $_sobrenome';
  }


// Methods
  void fazerAniversario() {
    _idade++;
    print('Feliz aniversário, $_nome! Agora você tem $_idade anos.');
  }

  void exibirDetalhes() {
    print('Nome: ${getNomeCompleto()}');
    print('Idade: $_idade');

  }
}

/*
// Constructor
Pessoa(String nome, String sobrenome) {
  _nome = nome;
  _sobrenome = sobrenome;
}
*/

/*
// Override toString method
@override
  String toString() {
    return {
      "nome": _nome,
      "sobrenome": _sobrenome,
      "idade": _idade,
      "cpf": _cpf
    }.toString();
  }

*/