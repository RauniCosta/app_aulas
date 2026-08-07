import 'dart:async';
import 'package:flutter/material.dart';
import '../models/turma_model.dart';
import '../services/json_service.dart';

class PainelTV extends StatefulWidget {
  const PainelTV({super.key});

  @override
  State<PainelTV> createState() => _PainelTVState();
}

class _PainelTVState extends State<PainelTV> {
  

  // Definição dos horários conforme sua solicitação
  final Map<String, List<String>> _horariosPorTurno = {
    "Manhã": ["07:10\n08:00", "08:00\n08:50", "08:50\n09:40", "10:00\n10:50", "10:50\n11:40", "11:40\n12:30"],
    "Tarde": ["12:40\n13:30", "13:30\n14:20", "14:20\n15:10", "15:30\n16:20", "16:20\n17:10", "17:10\n18:00", "18:00\n18:50"],
    "Noite": ["16:20\n17:10", "17:10\n18:00", "18:20\n19:10", "19:10\n20:00", "20:00\n20:50", "21:05\n21:55", "21:55\n22:45"],
  };
  
  final JsonService _jsonService = JsonService();
  List<Turma> _todasAsTurmas = [];
  
  // Lista de páginas. Cada página é uma lista de até 4 turmas da mesma modalidade.
  List<List<Turma>> _paginas = []; 
  
  late PageController _pageController;
  int _indicePaginaAtual = 0;
  Timer? _timerCarrossel;
  Timer? _timerRelogio; // Para atualizar a hora na tela

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _carregarDadosIniciais();

    // Atualiza a hora no topo da tela a cada minuto
    _timerRelogio = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {}); 
    });
  }

  void _carregarDadosIniciais() async {
    final dados = await _jsonService.carregarTurmas();
    _todasAsTurmas = dados;
    _gerarPaginasDoTurno();

    // Carrossel: Troca de tela a cada 10 segundos
    _timerCarrossel = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_paginas.isEmpty) return;
      
      // Antes de trocar, verifica se o turno mudou (ex: virou de manhã para tarde)
      _gerarPaginasDoTurno(); 

      if (_paginas.isNotEmpty) {
        _indicePaginaAtual = (_indicePaginaAtual + 1) % _paginas.length;
        _pageController.animateToPage(
          _indicePaginaAtual,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _obterDiaAtual() {
    int diaDaSemana = DateTime.now().weekday; // 1 = Segunda, 7 = Domingo
    switch (diaDaSemana) {
      case 1: return "Segunda";
      case 2: return "Terça";
      case 3: return "Quarta";
      case 4: return "Quinta";
      case 5: return "Sexta";
      default: return "Segunda"; // Fim de semana mostra a grade de segunda por padrão
    }
  }
  // 1. LÓGICA DO RELÓGIO: Descobre qual é o turno agora
  String _obterTurnoAtual() {
    final agora = DateTime.now();
    final horaDecimal = agora.hour + (agora.minute / 60.0);

    // Ajuste de horários conforme sua regra:
    if (horaDecimal < 12.66) return "Manhã"; // Antes das 12:40
    if (horaDecimal < 18.83) return "Tarde"; // Antes das 18:50
    return "Noite";                          // Depois das 18:50
  }

  // 2. LÓGICA DE AGRUPAMENTO: Separa Médio e Modular
  void _gerarPaginasDoTurno() {
    String turnoAtual = _obterTurnoAtual();
    
    // Pega só as turmas do turno que estamos agora
    var turmasAtivas = _todasAsTurmas.where((t) => t.turno == turnoAtual).toList();

    var ensinoMedio = turmasAtivas.where((t) => t.modalidade == "Ensino Médio").toList();
    var modular = turmasAtivas.where((t) => t.modalidade == "Modular").toList();

    List<List<Turma>> novasPaginas = [];

    // Fatiar Ensino Médio de 4 em 4
    for (var i = 0; i < ensinoMedio.length; i += 4) {
      novasPaginas.add(ensinoMedio.sublist(i, i + 4 > ensinoMedio.length ? ensinoMedio.length : i + 4));
    }
    // Fatiar Modular de 4 em 4
    for (var i = 0; i < modular.length; i += 4) {
      novasPaginas.add(modular.sublist(i, i + 4 > modular.length ? modular.length : i + 4));
    }

    if (mounted) {
      setState(() {
        _paginas = novasPaginas;
      });
    }
  }

  @override
  void dispose() {
    _timerCarrossel?.cancel();
    _timerRelogio?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String turnoAtual = _obterTurnoAtual();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "QUADRO DE SALAS • ${_obterDiaAtual().toUpperCase()} • $turnoAtual", 
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[900], // Azul mais escuro e elegante
        foregroundColor: Colors.white,
        toolbarHeight: 80, // AppBar maior para a TV
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Center(
              child: Text(
                "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          )
        ],
      ),
      body: _paginas.isEmpty
          ? Center(child: Text("Nenhuma turma programada para o período da $turnoAtual.", style: const TextStyle(fontSize: 24, color: Colors.grey)))
          : PageView.builder(
              controller: _pageController,
              itemCount: _paginas.length,
              itemBuilder: (context, index) {
                final turmasDaPagina = _paginas[index];
                
                // Decide qual tabela desenhar baseado na modalidade
                if (turmasDaPagina.first.modalidade == "Modular") {
                  return _tabelaModular(turmasDaPagina);
                } else {
                  return _tabelaEnsinoMedio(turmasDaPagina);
                }
              },
            ),
    );
  }

  // 🎨 DESIGN 1: Tabela para Ensino Médio (6 Aulas de 50min)
 Widget _tabelaEnsinoMedio(List<Turma> turmas) {
    String turno = _obterTurnoAtual();
    List<String> horarios = _horariosPorTurno[turno] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
        headingRowHeight: 90,
        dataRowMinHeight: 110,
        dataRowMaxHeight: 130,
        columnSpacing: 5,
        columns: [
          const DataColumn(label: Text('TURMA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24))),
          // Gera as colunas de horário dinamicamente
          ...List.generate(horarios.length, (index) => DataColumn(
            label: Expanded(
              child: Text(
                '${index + 1}ª\n${horarios[index]}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
          )),
        ],
        rows: turmas.map((t) => DataRow(cells: [
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.nome, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28)),
                Text(t.modalidade, style: const TextStyle(fontSize: 16, color: Colors.indigo)),
              ],
            )
          ),
          // Preenche as aulas da turma (limitado ao número de horários do turno)
          ...List.generate(horarios.length, (i) {
            String dia = _obterDiaAtual();
            String sala = (t.aulas[dia] != null && i < t.aulas[dia]!.length) ? t.aulas[dia]![i] : "-";
            return DataCell(
              Center(
                child: Text(sala, style: TextStyle(
                  fontSize: 40,
                  color: sala == "E.F." ? Colors.blue[800] : Colors.black87,
                  fontWeight: FontWeight.w900,
                )),
              ),
            );
          }),
        ])).toList(),
      ),
    );
  }
  
  // 🎨 DESIGN 2: Tabela para Modular (2 Blocos)
  Widget _tabelaModular(List<Turma> turmas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.amber[100]), // Cor diferente para destacar
        headingRowHeight: 90,
        dataRowMinHeight: 140,
        dataRowMaxHeight: 160,
        columns: const [
          DataColumn(label: Text('TURMA MODULAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28))),
          DataColumn(label: Center(child: Text('1º BLOCO\n(19:00 - 20:55)', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)))),
          DataColumn(label: Center(child: Text('2º BLOCO\n(21:05 - 23:00)', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)))),
        ],
        rows: turmas.map((t) => DataRow(cells: [
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.nome, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 36)),
                const Text("Curso Modular", style: TextStyle(fontSize: 20, color: Colors.deepOrange)),
              ],
            )
          ),
          // Pegamos apenas os índices 0 e 1, que o Admin preencheu
          DataCell(Center(child: Text((t.aulas[_obterDiaAtual()]?.isNotEmpty ?? false) ? t.aulas[_obterDiaAtual()]![0] : "-", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)))),
          DataCell(Center(child: Text((t.aulas[_obterDiaAtual()]?.length ?? 0) > 1 ? t.aulas[_obterDiaAtual()]![1] : "-", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)))),
        ])).toList(),
      ),
    );
  }
}