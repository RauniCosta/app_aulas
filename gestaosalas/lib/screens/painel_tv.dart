import 'package:flutter/material.dart';
import '../models/turma_model.dart';

class PainelTV extends StatefulWidget {
  @override
  _PainelTVState createState() => _PainelTVState();
}

class _PainelTVState extends State<PainelTV> {
  // Lista de dados
  // lib/screens/painel_tv.dart (Atualize a listaDeTurmas)

  // 1. Lista global com todas as salas físicas da escola
  final List<String> todasAsSalas = [
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
    'LAB 1',
    'LAB 2',
  ];

  // 2. Função que filtra o que está livre
  List<String> getSalasLivres(int indexAula) {
    List<String> ocupadas = listaDeTurmas
        .map((t) => t.aulas[indexAula])
        .toList();
    // Retorna apenas as salas que NÃO estão na lista de ocupadas
    return todasAsSalas.where((s) => !ocupadas.contains(s)).toList();
  }

  final List<Turma> listaDeTurmas = [
    // Página 1
    Turma(
      nome: '1º CHSA',
      aulas: ['E.F.', 'E.F.', 'B3', 'A10/A9', 'B3', 'C5'],
    ), //[cite: 5, 6, 7, 8, 9]
    Turma(
      nome: '1º ADM',
      aulas: ['C1', 'C1', 'E.F.', 'C6', 'C6', '-'],
    ), //[cite: 10, 11, 12, 13, 14, 15]
    Turma(
      nome: '1º DS',
      aulas: ['C2', 'C2', 'C2', 'C2', 'B1/B2', 'B1/B2'],
    ), //[cite: 16, 17, 18, 19, 20, 21]
    Turma(
      nome: '1º MKT',
      aulas: ['B1/B2', 'B1/B2', 'C1', 'C1', 'C1', 'C1'],
    ), // [cite: 22, 23, 24, 25]
    // Página 2
    Turma(
      nome: '2º CHSA',
      aulas: ['B5', 'B5', 'B5', 'B5', 'B5', 'C6'],
    ), // [cite: 26]
    Turma(
      nome: '2º ADM',
      aulas: ['C3', 'C3', 'C3', 'C4', 'C4', '-'],
    ), // [cite: 26]
    Turma(
      nome: '2º MKT',
      aulas: ['B6', 'B6', 'B6', 'E.F.', 'C2', 'C2'],
    ), // [cite: 26]
    Turma(
      nome: '2º DS',
      aulas: ['C5', 'C5', 'C5', 'B6', 'B6', '-'],
    ), //[cite: 26]
    // Página 3
    Turma(
      nome: '3º CHSA',
      aulas: ['C4', 'C4', 'C4', 'C4', 'A6', 'A6'],
    ), //[cite: 33, 34, 35, 36, 37, 38]
    Turma(
      nome: '3º ADM',
      aulas: ['A6', 'A6', 'A6', 'A6', 'B1/B2', 'B1/B2'],
    ), // //[cite: 39, 40, 41, 42, 43, 44]
    Turma(
      nome: '3º DS',
      aulas: ['B3', 'B3', 'B1/A3', 'B1/A3', 'A9/A10', '-'],
    ), //[cite: 45, 46, 47, 48]
    Turma(
      nome: '3º MKT',
      aulas: ['A9', 'C6', 'C6', 'C3/B4', 'C3/B4', 'C3'],
    ), //[cite: 49, 50, 51, 52]
    // Página 4
    Turma(
      nome: '1º ENF',
      aulas: ['A7', 'A7', 'A7', 'A7', 'A7', 'A8'],
    ), //[cite: 54]
    Turma(
      nome: '3º ENF',
      aulas: ['A8', 'A8', 'A8', 'A8', 'A8', '-'],
    ), //[cite: 54]
  ];

  bool existeConflito(String salaNova, int indiceAula, String nomeTurmaAtual) {
    // Se for Educação Física ou vazio, não há conflito de sala física
    if (salaNova == 'E.F.' || salaNova == '-' || salaNova.isEmpty) {
      return false;
    }

    for (var turma in listaDeTurmas) {
      // Só verificamos as OUTRAS turmas, não a que estamos editando
      if (turma.nome != nomeTurmaAtual) {
        // Se na mesma aula (coluna), a sala for igual à que queremos colocar...
        if (turma.aulas[indiceAula] == salaNova) {
          return true; // CONFLITO DETECTADO!
        }
      }
    }
    return false; // Caminho livre
  }

  void _abrirSeletorDeSalas(int indexTurma, int indexAula) {
    List<String> selecionadas = [];
    List<String> disponiveis = getSalasLivres(indexAula);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Necessário para atualizar o diálogo
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Selecione as Salas (Máx. 2)"),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              children: disponiveis
                  .map(vamos 
                    (sala) => CheckboxListTile(
                      title: Text(sala),
                      value: selecionadas.contains(sala),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value!) {
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
            ElevatedButton(
              child: Text("Confirmar"),
              onPressed: () {
                setState(() {
                  // Junta as salas com uma barra, ex: "B1/B2"
                  listaDeTurmas[indexTurma].aulas[indexAula] = selecionadas
                      .join('/');
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Função para mudar a sala (Simulando a interatividade)
  void _editarSala(int indexTurma, int indexAula) {
    String turmaNome = listaDeTurmas[indexTurma].nome;

    showDialog(
      context: context,
      builder: (context) {
        String temporario = "";
        return AlertDialog(
          title: Text('Definir sala para $turmaNome'),
          content: TextField(
            onChanged: (val) => temporario = val.toUpperCase(),
            decoration: InputDecoration(hintText: "Ex: C1, B3, A7"),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () {
                // A MÁGICA ACONTECE AQUI:
                if (existeConflito(temporario, indexAula, turmaNome)) {
                  // Mostra um aviso se houver erro
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'ERRO: A sala $temporario já está ocupada nesta aula!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // Se não houver conflito, salva os dados
                  setState(() {
                    listaDeTurmas[indexTurma].aulas[indexAula] = temporario;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GESTOR DE SALAS - QUARTA MANHÃ [cite: 1]')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width, // Ocupa largura total
          height: MediaQuery.of(context).size.height, // Ocupa altura total
          child: DataTable(
            columnSpacing: 20, // Ajusta o espaço entre colunas
            dataRowMinHeight:
                60, // Aumenta a altura da linha para a letra caber
            dataRowMaxHeight: 100,
            headingRowColor: MaterialStateProperty.all(Colors.blueGrey[50]),
            columns: const [
              DataColumn(label: Text('TURMA')),
              DataColumn(label: Text('1ª')),
              DataColumn(label: Text('2ª')),
              DataColumn(label: Text('3ª')),
              DataColumn(label: Text('4ª')),
              DataColumn(label: Text('5ª')),
              DataColumn(label: Text('6ª')),
            ],
            rows: List.generate(listaDeTurmas.length, (indexT) {
              var turma = listaDeTurmas[indexT];
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      turma.nome,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...List.generate(turma.aulas.length, (indexA) {
                    String sala = turma.aulas[indexA];
                    return DataCell(
                      Container(
                        padding: EdgeInsets.all(8),
                        // Lógica de cores: Cinza para E.F. [cite: 6]
                        color: sala == 'E.F.'
                            ? Colors.grey[300]
                            : Colors.transparent,
                        child: Text(sala),
                      ),
                      onTap: () => _editarSala(
                        indexT,
                        indexA,
                      ), // Abre o editor ao clicar
                    );
                  }),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
