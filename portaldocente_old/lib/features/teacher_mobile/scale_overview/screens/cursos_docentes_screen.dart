// Ficheiro: lib/features/teacher_mobile/scale_overview/screens/cursos_docentes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider de Mock para a Matriz
// Num cenário real, isto cruzaria os dados de Cursos, UCs e Escalas da semana
final matrizSemanalProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'curso': 'Téc. Informática',
      'segunda': {'uc': 'Sistemas Operacionais', 'docentes': ['Ricardo']},
      'terca': {'uc': 'Banco de Dados', 'docentes': ['Ricardo', 'Paulo']},
      'quarta': {'uc': 'Banco de Dados', 'docentes': ['Paulo']},
      'quinta': {'uc': 'Sistemas Operacionais', 'docentes': ['Ricardo', 'Paulo']},
      'sexta': {'uc': 'Redes', 'docentes': ['Ana']},
    },
    {
      'curso': 'Des. Sistemas',
      'segunda': {'uc': 'Lógica de Prog.', 'docentes': ['Ricardo']},
      'terca': {'uc': 'Lógica de Prog.', 'docentes': ['Ricardo']},
      'quarta': null, // Dia livre
      'quinta': {'uc': 'Front-end', 'docentes': ['Ana']},
      'sexta': {'uc': 'Front-end', 'docentes': ['Ana', 'Ricardo']},
    },
  ];
});

class CursosDocentesScreen extends ConsumerWidget {
  const CursosDocentesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matriz = ref.watch(matrizSemanalProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BB2),
        elevation: 0,
        title: const Text('Visão Geral da Semana', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Alocação de Docentes por Curso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          // 2. Tabela com Scroll Horizontal
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: DataTable(
                    columnSpacing: 25,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(label: Text('Cursos', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Segunda')),
                      DataColumn(label: Text('Terça')),
                      DataColumn(label: Text('Quarta')),
                      DataColumn(label: Text('Quinta')),
                      DataColumn(label: Text('Sexta')),
                    ],
                    rows: matriz.map((linha) {
                      return DataRow(
                        cells: [
                          DataCell(Text(linha['curso'], style: const TextStyle(fontWeight: FontWeight.bold))),
                          _buildCelulaDia(linha['segunda']),
                          _buildCelulaDia(linha['terca']),
                          _buildCelulaDia(linha['quarta']),
                          _buildCelulaDia(linha['quinta']),
                          _buildCelulaDia(linha['sexta']),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // WIDGET AUXILIAR: Desenha a UC e os Avatares dentro da célula da tabela
  DataCell _buildCelulaDia(Map<String, dynamic>? dadosDia) {
    if (dadosDia == null) {
      return const DataCell(Center(child: Text('-', style: TextStyle(color: Colors.grey))));
    }

    List<String> docentes = dadosDia['docentes'];

    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(dadosDia['uc'], style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: docentes.map((nome) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: const Color(0xFF1E5BB2).withOpacity(0.2),
                    child: Text(nome[0], style: const TextStyle(fontSize: 10, color: Color(0xFF1E5BB2), fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}