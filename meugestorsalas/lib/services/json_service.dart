import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/turma_model.dart';

class JsonService {
  // O "nome do arquivo" virtual dentro do cofre do navegador
  final String _chaveBanco = 'banco_de_dados_escola';

  // 1. Salva o banco de dados completo (Usado no Setup Wizard)
  Future<void> salvarBancoCompleto(List<String> salas, List<Turma> turmas) async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, dynamic> data = {
      'salas': salas,
      'turmas': turmas.map((t) => t.toJson()).toList()
    };
    
    final String jsonString = json.encode(data);
    await prefs.setString(_chaveBanco, jsonString);
    print("Sucesso! Banco de dados salvo na memória do navegador!");
  }

  // NOVA FUNÇÃO: Atualiza apenas as turmas (Usado no Admin Panel)
  Future<void> salvarDadosLocais(List<Turma> turmasAtualizadas) async {
    // Primeiro, recuperamos as salas que já estão salvas para não perdê-las
    List<String> salasExistentes = await carregarSalas();
    
    // Depois, usamos a função principal para salvar tudo junto
    await salvarBancoCompleto(salasExistentes, turmasAtualizadas);
    print("Turmas atualizadas com sucesso!");
  }

  // Função auxiliar para ler os dados do cofre
  Future<Map<String, dynamic>?> _lerDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_chaveBanco);
    
    if (jsonString != null) {
      return json.decode(jsonString); 
    }
    return null; 
  }

  // 2. Carrega apenas a lista de Turmas
  Future<List<Turma>> carregarTurmas() async {
    final dados = await _lerDados();
    if (dados != null && dados['turmas'] != null) {
      List<dynamic> turmasJson = dados['turmas'];
      return turmasJson.map((json) => Turma.fromJson(json)).toList();
    }
    return [];
  }

  // 3. Carrega apenas a lista de Salas
  Future<List<String>> carregarSalas() async {
    final dados = await _lerDados();
    if (dados != null && dados['salas'] != null) {
      return List<String>.from(dados['salas']);
    }
    return [];
  }
}