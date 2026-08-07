
import 'package:app_exe_ex/exception/nome_invalido.dart';
import 'package:app_exe_ex/models/Aluno.dart';
import 'package:app_exe_ex/models/console_utils.dart';

void execute() {

  print('Executando a aplicação de Notas de Alunos');
  print('---------------------------------------');

  String nomeAluno = ConsoleUtils.lerStringComTxt('Digite o nome do aluno: ');
  if (nomeAluno.trim() == "") {
    throw NomeInvalidoException();
    
  }

// Criar objeto Aluno com o nome digitado pelo usuário
  var aluno = Aluno(nomeAluno);
  double? nota;

// Loop para adicionar notas até o usuário digitar "sair"
  do {
    nota = ConsoleUtils.lerDoubleComTxt('Digite a nota do aluno ou "sair" para finalizar: ');
    if (nota != null) {
      aluno.adicionarNota(nota);
    }
  } while (nota != null);
  
  print('---------------------------------------'); 
  print('---------------------------------------'); 
  print('---------------------------------------'); 
  

// Exibir informações do aluno
  print('Relatório do Aluno');
  print('---------------------------------------');
  print('Aluno: ${aluno.getNome()}');
  print(aluno.getNotas());
  print('Nota Média: ${aluno.calcularMedia()}');
  if (aluno.aprovado(aluno.calcularMedia())) {
    print('Status: Aprovado');
  } else {
    print('Status: Reprovado');
  }
  
 
}
