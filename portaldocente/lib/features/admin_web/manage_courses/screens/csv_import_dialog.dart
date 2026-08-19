import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../../../../data/models/unidade_curricular_model.dart';

class CsvImportDialog extends StatefulWidget {
  final String cursoId;

  const CsvImportDialog({Key? key, required this.cursoId}) : super(key: key);

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  bool _processando = false;
  String _nomeArquivo = '';
  List<UnidadeCurricularModel> _ucsExtraidas = [];

  Future<void> _selecionarEProcessarCsv() async {

    // Código original desativado temporariamente para compilação.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Módulo de importação desativado temporariamente para testes de compilação.'),
        backgroundColor: Colors.orange,
      ),
    );
    /*
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _processando = true;
        _nomeArquivo = result.files.single.name;
        _ucsExtraidas.clear();
      });

      try {
        final Uint8List bytes = result.files.single.bytes!;
        // Decodifica os bytes (tenta UTF-8 para manter os acentos corretos)
        final String csvString = utf8.decode(bytes, allowMalformed: true);

        // Converte o texto CSV para uma lista do Dart (considerando ponto e vírgula como separador do Excel)
        List<List<dynamic>> linhas = const CsvToListConverter(
          fieldDelimiter: ';',
          textDelimiter: '"',
          eol: '\n',
        ).convert(csvString);

        final List<UnidadeCurricularModel> ucsEncontradas = [];

        // Começa do índice 1 para pular o Cabeçalho da planilha
        for (int i = 1; i < linhas.length; i++) {
          final linha = linhas[i];
          
          if (linha.isEmpty || linha[0].toString().trim().isEmpty) continue;

          String nomeUC = linha[0].toString().trim();
          int horas = linha.length > 1 ? (int.tryParse(linha[1].toString()) ?? 60) : 60;
          String modulo = linha.length > 2 ? linha[2].toString().trim() : 'Modulo 1';

          ucsEncontradas.add(UnidadeCurricularModel(
            id: "",
            cursoId: widget.cursoId,
            nome: nomeUC,
            cargaHoraria: horas,
            moduloOuSemestre: modulo,
          ));
        }

        setState(() {
          _ucsExtraidas = ucsEncontradas;
          _processando = false;
        });

      } catch (e) {
        setState(() => _processando = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao ler CSV: O arquivo deve estar separado por ponto e vírgula (;).'), backgroundColor: Colors.red),
          );
        }
      }
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar UCs via Planilha (CSV)'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A planilha deve ter 3 colunas (separadas por ponto e vírgula):\n1. Nome da UC\n2. Carga Horária (apenas número)\n3. Módulo (Ex: Modulo 1)',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _processando ? null : _selecionarEProcessarCsv,
                icon: const Icon(Icons.upload_file),
                label: Text(_processando ? 'Processando...' : 'Selecionar Arquivo .CSV'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5BB2)),
              ),
            ),
            if (_nomeArquivo.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text('Arquivo: $_nomeArquivo', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: _ucsExtraidas.isEmpty && !_processando
                    ? const Center(child: Text('Nenhuma disciplina encontrada.'))
                    : ListView.builder(
                        itemCount: _ucsExtraidas.length,
                        itemBuilder: (context, index) {
                          final uc = _ucsExtraidas[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(uc.nome),
                            subtitle: Text('${uc.cargaHoraria}h | ${uc.moduloOuSemestre}'),
                          );
                        },
                      ),
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _ucsExtraidas.isEmpty
              ? null
              : () => Navigator.pop(context, _ucsExtraidas),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Importar ${_ucsExtraidas.length} UCs'),
        ),
      ],
    );
  }
}