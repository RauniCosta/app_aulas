import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialGestorApp());
}

class MaterialGestorApp extends StatelessWidget {
  const MaterialGestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Salas - Quarta Manhã',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const PainelGestaoScreen(),
    );
  }
}

// Modelo de Dados (Etapa 1 e 3)
class Turma {
  final String nome;
  final List<String> aulas;
  Turma({required this.nome, required this.aulas});
}

class PainelGestaoScreen extends StatefulWidget {
  const PainelGestaoScreen({super.key});

  @override
  State<PainelGestaoScreen> createState() => _PainelGestaoScreenState();
}

class _PainelGestaoScreenState extends State<PainelGestaoScreen> {
  // Controle do Carrossel
  late PageController _pageController;
  int _paginaAtual = 0;
  Timer? _timer;

  // Lista de Salas Totais da Escola (Pode ser expandida)
  final List<String> todasAsSalas = [
    'A3',
    'A6',
    'A7',
    'A8',
    'A9',
    'A10',
    'B1',
    'B2',
    'B3',
    'B4',
    'B5',
    'B6',
    'C1',
    'C2',
    'C3',
    'C4',
    'C5',
    'C6',
    'E.F.',
  ];

  // Dados extraídos diretamente do seu documento
  late List<Turma> listaDeTurmas;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    listaDeTurmas = [
      Turma(
        nome: '1º CHSA',
        aulas: ['E.F.', 'E.F.', 'B3', 'A10/A9', 'B3', 'C5'],
      ),
      Turma(nome: '1º ADM', aulas: ['C1', 'C1', 'E.F.', 'C6', 'C6', '-']),
      Turma(nome: '1º DS', aulas: ['C2', 'C2', 'C2', 'C2', 'B1/B2', 'B1/B2']),
      Turma(nome: '2º CHSA', aulas: ['B5', 'B5', 'B5', 'B5', 'B5', 'C6']),
      Turma(nome: '2º ADM', aulas: ['C3', 'C3', 'C3', 'C4', 'C4', '-']),
      Turma(nome: '2º MKT', aulas: ['B6', 'B6', 'B6', 'E.F.', 'C2', 'C2']),
      Turma(nome: '3º CHSA', aulas: ['C4', 'C4', 'C4', 'C4', 'A6', 'A6']),
      Turma(nome: '3º ADM', aulas: ['A6', 'A6', 'A6', 'A6', 'B1/B2', 'B1/B2']),
      Turma(nome: '1º ENF', aulas: ['A7', 'A7', 'A7', 'A7', 'A7', 'A8']),
      Turma(nome: '3º ENF', aulas: ['A8', 'A8', 'A8', 'A8', 'A8', '-']),
    ];

    // Configura a troca automática a cada 10 segundos
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      int totalPaginas = (listaDeTurmas.length / 4).ceil();
      if (_paginaAtual < totalPaginas - 1) {
        _paginaAtual++;
      } else {
        _paginaAtual = 0;
      }
      _pageController.animateToPage(
        _paginaAtual,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Lógica: Filtra salas que não estão ocupadas na aula X
  List<String> getSalasDisponiveis(int indexAula, String turmaAtual) {
    List<String> ocupadas = [];
    for (var t in listaDeTurmas) {
      if (t.nome != turmaAtual) {
        // Separa casos de salas divididas (ex: A10/A9) para checar individualmente
        ocupadas.addAll(t.aulas[indexAula].split('/'));
      }
    }
    return todasAsSalas
        .where((s) => !ocupadas.contains(s) || s == 'E.F.')
        .toList();
  }

  void _abrirSeletor(int idxTurma, int idxAula) {
    List<String> disponiveis = getSalasDisponiveis(
      idxAula,
      listaDeTurmas[idxTurma].nome,
    );
    List<String> selecionadas = listaDeTurmas[idxTurma].aulas[idxAula]
        .split('/')
        .where((s) => s != '-')
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "Alocação: ${listaDeTurmas[idxTurma].nome} (${idxAula + 1}ª Aula)",
          ),
          content: SizedBox(
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: disponiveis
                  .map(
                    (sala) => CheckboxListTile(
                      title: Text(sala),
                      value: selecionadas.contains(sala),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val!) {
                            if (selecionadas.length < 2) selecionadas.add(sala);
                          } else {
                            selecionadas.remove(sala);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  listaDeTurmas[idxTurma].aulas[idxAula] = selecionadas.isEmpty
                      ? '-'
                      : selecionadas.join('/');
                });
                Navigator.pop(context);
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para dividir a lista em pedaços de 4
    int turmasPorPagina = 4;
    int totalDePaginas = (listaDeTurmas.length / turmasPorPagina).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text("GESTOR DE SALAS - QUARTA MANHÃ")),
      body: PageView.builder(
        controller: _pageController,
        itemCount: totalDePaginas,
        itemBuilder: (context, pageIndex) {
          // Pega apenas as 4 turmas daquela página específica
          int inicio = pageIndex * turmasPorPagina;
          int fim = (inicio + turmasPorPagina < listaDeTurmas.length)
              ? inicio + turmasPorPagina
              : listaDeTurmas.length;

          List<Turma> turmasDaPagina = listaDeTurmas.sublist(inicio, fim);

          return _construirTabela(turmasDaPagina);
        },
      ),
    );
  }

  // Widget da Tabela (Refatorado para aceitar a sublista)
  Widget _construirTabela(List<Turma> turmas) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          dataRowMinHeight: 100, // Aumentado para 4 linhas ocuparem a tela
          dataRowMaxHeight: 120,
          columnSpacing: 40,
          columns: const [
            DataColumn(
              label: Text(
                'TURMA',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(label: Text('1ª', style: TextStyle(fontSize: 22))),
            DataColumn(label: Text('2ª', style: TextStyle(fontSize: 22))),
            DataColumn(label: Text('3ª', style: TextStyle(fontSize: 22))),
            DataColumn(label: Text('4ª', style: TextStyle(fontSize: 22))),
            DataColumn(label: Text('5ª', style: TextStyle(fontSize: 22))),
            DataColumn(label: Text('6ª', style: TextStyle(fontSize: 22))),
          ],
          rows: turmas.map((turma) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    turma.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...turma.aulas
                    .map(
                      (sala) => DataCell(
                        Center(
                          child: Text(
                            sala,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
