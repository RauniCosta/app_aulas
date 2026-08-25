// Ficheiro: lib/features/admin_web/manage_courses/screens/csv_import_dialog.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
        // Decodifica usando UTF-8 para garantir que os acentos (ç, ã, é) fiquem perfeitos
        final String csvString = utf8.decode(bytes, allowMalformed: true);

        // Converte o CSV para uma lista Dart (ponto e vírgula é o padrão do Excel no Brasil)
        List<List<dynamic>> linhas = const CsvToListConverter(
          fieldDelimiter: ';',
          textDelimiter: '"',
          eol: '\n',
        ).convert(csvString);

        final List<UnidadeCurricularModel> ucsEncontradas = [];

        // Começa do índice 1 para pular a primeira linha (Cabeçalho da planilha)
        for (int i = 1; i < linhas.length; i++) {
          final linha = linhas[i];
          if (linha.isEmpty || linha[0].toString().trim().isEmpty) continue;

          String nomeUC = linha[0].toString().trim();
          int horas = linha.length > 1 ? (int.tryParse(linha[1].toString()) ?? 60) : 60;
          String modulo = linha.length > 2 ? linha[2].toString().trim() : 'Módulo 1';

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
            const SnackBar(
              content: Text('Erro ao ler CSV: Salve sua planilha como "CSV (separado por vírgulas)" no Excel.'), 
              backgroundColor: Colors.red
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Importar UCs em Massa (CSV)'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Sua planilha Excel deve ter 3 colunas:\n1. Nome da Disciplina\n2. Carga Horária (Apenas números)\n3. Módulo/Semestre',
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _processando ? null : _selecionarEProcessarCsv,
                icon: const Icon(Icons.upload_file),
                label: Text(_processando ? 'Processando...' : 'Selecionar Planilha .CSV'),
              ),
            ),
            if (_nomeArquivo.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text('Arquivo: $_nomeArquivo', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: _ucsExtraidas.isEmpty && !_processando
                    ? const Center(child: Text('Nenhuma disciplina encontrada na planilha.'))
                    : ListView.builder(
                        itemCount: _ucsExtraidas.length,
                        itemBuilder: (context, index) {
                          final uc = _ucsExtraidas[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(uc.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          child: Text('Importar ${_ucsExtraidas.length} UCs'),
        ),
      ],
    );
  }
}