import 'package:http/http.dart' as http;
import 'dart:convert';

class Viacep {
  /// Realiza a consulta de CEP de forma assíncrona.
  /// Utiliza [Future] para indicar que o resultado será retornado no futuro,
  /// permitindo que a aplicação não trave durante a requisição HTTP.
  Future<Map<dynamic, dynamic>> consultaCEP(String cep) async {
    // Define a URI (Uniform Resource Identifier) para o endpoint da API ViaCEP.
    var uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    
    // O comando [await] pausa a execução da função até que a requisição HTTP GET seja concluída.
    var retorno = await http.get(uri);
    
    // Decodifica o corpo da resposta (JSON) para um Map, garantindo a codificação UTF-8.
    var consulta = jsonDecode(utf8.decode(retorno.bodyBytes)) as Map;
    print(consulta);

    return consulta;
  }

  dynamic retornarCEP(String cep) async {
    var uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    var retorno = await http.get(uri);
    return retorno.body;
  }
}
