import 'dart:convert'; // Para converter String para JSON
import 'package:http/http.dart' as http;
import '../models/tarefa.dart';

class ApiService {
  // Vamos usar uma API pública de testes que retorna tarefas
  final String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  // READ (Ler tarefas da internet - GET)
  Future<List<Tarefa>> obterTarefasOnline() async {
    try {
      // Fazendo o pedido para a internet
      final response = await http.get(Uri.parse(baseUrl));

      // Verificando se o servidor respondeu com sucesso (Código 200 = OK)
      if (response.statusCode == 200) {
        // A internet devolve um textão (String). Precisamos converter para JSON (Lista)
        List<dynamic> jsonList = json.decode(response.body);

        // Pegamos os 10 primeiros resultados e transformamos no nosso Objeto Tarefa
        return jsonList.take(10).map((json) => Tarefa(
          id: json['id'],
          titulo: json['title'],
          descricao: 'Tarefa vinda da Nuvem ☁️', // A API não tem descrição, criamos uma falsa
          concluida: json['completed'] ? 1 : 0, 
        )).toList();
      } else {
        // Tratamento de exceção como sugerido na literatura
        throw Exception('Erro no servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha de conexão. Verifique sua internet. Detalhes: $e');
    }
  }

  // CREATE (Simulando salvar na internet - POST)
  Future<void> inserirTarefaOnline(Tarefa tarefa) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'title': tarefa.titulo,
        'completed': tarefa.concluida == 1 ? true : false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 201) { // 201 = Created
      print("Tarefa criada na nuvem com sucesso! ID gerado: ${json.decode(response.body)['id']}");
    } else {
      throw Exception('Falha ao criar tarefa online.');
    }
  }
  
  // Nota para a aula: Os métodos PUT e DELETE seguiriam a mesma lógica usando http.put e http.delete
}