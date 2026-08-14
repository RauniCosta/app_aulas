import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart'; // Cores oficias do VS Code

void main() {
  runApp(const LeitorCodigoApp());
}

// Widget base do aplicativo
class LeitorCodigoApp extends StatelessWidget {
  const LeitorCodigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visualizador Dev',
      theme: ThemeData.dark(), // Tema escuro
      debugShowCheckedModeBanner: false,
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<FileSystemEntity> _arquivos = [];
  String _conteudoArquivo = "Selecione uma pasta e clique em um arquivo para visualizar.";
  String _linguagemAtual = "txt";

  // Função para abrir o diretório usando o file_picker
  Future<void> _abrirPasta() async {
    try {
      String? caminho = await FilePicker.platform.getDirectoryPath();

      if (caminho != null) {
        setState(() {
          final dir = Directory(caminho);
          
          // Filtra os arquivos desejados
          _arquivos = dir.listSync().where((entidade) {
            if (entidade is File) {
              String nome = entidade.path.toLowerCase();
              return nome.endsWith('.dart') || 
                     nome.endsWith('.py') || 
                     nome.endsWith('.txt');
            }
            return false;
          }).toList();
          
          _conteudoArquivo = "Pasta carregada. Selecione um arquivo na lista.";
        });
      }
    } catch (e) {
      setState(() {
        _conteudoArquivo = "Erro ao abrir a pasta ou ler os arquivos.\nDetalhes: $e";
      });
    }
  }

  // Função para ler o conteúdo do arquivo clicado
  Future<void> _lerArquivo(File arquivo) async {
    try {
      String conteudo = await arquivo.readAsString();
      String extensao = arquivo.path.split('.').last.toLowerCase();
      String linguagem = 'txt';
      
      // Define a linguagem para o colorizador
      if (extensao == 'dart') linguagem = 'dart';
      if (extensao == 'py') linguagem = 'python';

      setState(() {
        _conteudoArquivo = conteudo;
        _linguagemAtual = linguagem;
      });
    } catch (e) {
      setState(() {
        _conteudoArquivo = "Erro ao tentar ler este arquivo.\nDetalhes: $e";
        _linguagemAtual = "txt";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeto Viewer - SM-T285M'),
        backgroundColor: const Color(0xFF252526),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _abrirPasta,
            tooltip: 'Abrir Diretório',
          ),
        ],
      ),
      // Layout dividido para Tablet
      body: Row(
        children: [
          // ESQUERDA: Lista de Arquivos (Tamanho fixo de 250 pixels)
          Container(
            width: 250,
            color: const Color(0xFF2D2D30),
            child: _arquivos.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum arquivo encontrado.\nAbra um diretório.",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _arquivos.length,
                    itemBuilder: (context, index) {
                      File arquivo = _arquivos[index] as File;
                      String nomeArquivo = arquivo.path.split(Platform.pathSeparator).last; 
                      
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                        title: Text(nomeArquivo, style: const TextStyle(fontSize: 14)),
                        onTap: () => _lerArquivo(arquivo),
                      );
                    },
                  ),
          ),
          
          // DIREITA: Visualizador de Código Fonte
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E), // Fundo principal escuro
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: HighlightView(
                  _conteudoArquivo,
                  language: _linguagemAtual,
                  theme: vs2015Theme, // Aplica as cores do VS Code
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}