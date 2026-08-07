import 'package:flutter/material.dart';
import '../models/turma_model.dart';
import '../services/json_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  String _diaSelecionado = "Segunda";
  final List<String> _diasDaSemana = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta"];

  final JsonService _jsonService = JsonService();
  late TabController _tabController;
  
  List<Turma> _todasAsTurmas = [];
  List<String> _todasAsSalas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDados();
  }

  void _carregarDados() async {
    final turmas = await _jsonService.carregarTurmas();
    final salas = await _jsonService.carregarSalas();
    setState(() {
      _todasAsTurmas = turmas;
      _todasAsSalas = salas;
      _carregando = false;
    });
  }

  void _salvar() async {
    await _jsonService.salvarDadosLocais(_todasAsTurmas);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configurações salvas com sucesso!")),
    );
  }

  // Função para adicionar nova sala ou turma dinamicamente
  void _gerenciarEstrutura() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.room),
            title: const Text("Adicionar Nova Sala"),
            onTap: () => _dialogNovaSala(),
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Adicionar Nova Turma"),
            onTap: () => _dialogNovaTurma(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: _diaSelecionado,
          dropdownColor: Colors.indigo[800],
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: _diasDaSemana.map((dia) => DropdownMenuItem(value: dia, child: Text("GERENCIAR: $dia"))).toList(),
          onChanged: (novoDia) {
            setState(() => _diaSelecionado = novoDia!);
          },
        ),
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "MANHÃ"), Tab(text: "TARDE"), Tab(text: "NOITE")],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save_as), onPressed: _salvar),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _listaPorTurno("Manhã"),
          _listaPorTurno("Tarde"),
          _listaPorTurno("Noite"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gerenciarEstrutura,
        label: const Text("ADICIONAR"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _listaPorTurno(String turno) {
    final turmasFiltradas = _todasAsTurmas.where((t) => t.turno == turno).toList();
    // Define quantas aulas mostrar no Admin (Manhã 6, outros 7)
    int qtdAulas = (turno == "Manhã") ? 6 : 7;

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: turmasFiltradas.length,
      itemBuilder: (context, index) {
        final t = turmasFiltradas[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Chip(label: Text(t.modalidade, style: const TextStyle(fontSize: 10))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Toque na aula para trocar a sala:"),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(qtdAulas, (i) {
                    // Proteção caso a turma no JSON tenha menos aulas que o turno exige
                    String salaAtual = (i < t.aulas.length) ? t.aulas[_diaSelecionado]![i] : "-";
                    return ActionChip(
                      backgroundColor: salaAtual == "-" ? Colors.grey[100] : Colors.indigo[50],
                      label: Text("${i + 1}ª: $salaAtual"),
                      onPressed: () => _seletorSala(t, i),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DIALOGS DE EDIÇÃO ---

  void _seletorSala(Turma turmaAtual, int aulaIndex) {
  // 1. Descobrir quais salas estão ocupadas por OUTRAS turmas neste horário
  List<String> salasOcupadas = [];
  
  for (var t in _todasAsTurmas) {
    // Não verificamos a própria turma que estamos editando
    if (t.nome != turmaAtual.nome && t.turno == turmaAtual.turno) {
      if (t.aulas[_diaSelecionado] != null && aulaIndex < t.aulas[_diaSelecionado]!.length) {
        // Se a sala for composta (ex: A10/A9), precisamos separar para bloquear ambas
        salasOcupadas.addAll(t.aulas[_diaSelecionado]![aulaIndex].split('/'));
      }
    }
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Selecionar Sala - ${aulaIndex + 1}ª Aula"),
     // subtitle: const Text("Salas em vermelho já estão ocupadas neste horário."),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          children: _todasAsSalas.map((sala) {
            // A sala "E.F." (Educação Física) e "-" geralmente podem ser repetidas
            bool estaOcupada = salasOcupadas.contains(sala) && sala != "E.F." && sala != "-";
            String salaNaAula = (turmaAtual.aulas[_diaSelecionado] != null && aulaIndex < turmaAtual.aulas[_diaSelecionado]!.length) 
                ? turmaAtual.aulas[_diaSelecionado]![aulaIndex] 
                : "-";
            bool selecionadaPelaTurma = salaNaAula.split('/').contains(sala);

            return InkWell(
              // Se estiver ocupada, o clique não faz nada
              onTap: estaOcupada ? null : () {
                setState(() {
                  List<String> selecionadasNoMomento = salaNaAula
                      .split('/')
                      .where((s) => s != "-")
                      .toList();

                  if (selecionadasNoMomento.contains(sala)) {
                    selecionadasNoMomento.remove(sala);
                  } else {
                    if (selecionadasNoMomento.length < 2) {
                      selecionadasNoMomento.add(sala);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Máximo de 2 salas por aula (Divisão)."))
                      );
                    }
                  }

                  turmaAtual.aulas[_diaSelecionado]![aulaIndex] = (selecionadasNoMomento.isEmpty ? "-" : selecionadasNoMomento.join('/'));
                });
                // Nota: Não fechamos o dialog para permitir selecionar 2 salas (divisão)
              },
              child: Opacity(
                opacity: estaOcupada ? 0.4 : 1.0, // Fica "apagadinho" se ocupada
                child: Card(
                  color: estaOcupada 
                      ? Colors.red[100] 
                      : (selecionadaPelaTurma ? Colors.amber[200] : null),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(sala, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (estaOcupada) const Text("OCUPADA", style: TextStyle(fontSize: 8, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Confirmar"))
      ],
    ),
  );
}

  void _dialogNovaSala() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova Sala Física"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Ex: Sala B9")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              setState(() => _todasAsSalas.add(controller.text.toUpperCase()));
              _jsonService.salvarBancoCompleto(_todasAsSalas, _todasAsTurmas);
              Navigator.pop(context);
              Navigator.pop(context);
            }, 
            child: const Text("Adicionar")
          ),
        ],
      ),
    );
  }

  void _dialogNovaTurma() {
  final TextEditingController nomeController = TextEditingController();
  String mod = "Ensino Médio";
  String turno = "Manhã";

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder( // StatefulBuilder para atualizar os Dropdowns dentro do Dialog
      builder: (context, setDialogState) => AlertDialog(
        title: const Text("Cadastrar Nova Turma"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome da Turma"),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: mod,
              decoration: const InputDecoration(labelText: "Modalidade"),
              items: ["Ensino Médio", "Modular"].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setDialogState(() => mod = val!),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: turno,
              decoration: const InputDecoration(labelText: "Turno"),
              items: ["Manhã", "Tarde", "Noite"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setDialogState(() => turno = val!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
                if (nomeController.text.isNotEmpty) {
                // Define a quantidade de aulas iniciais baseada no turno
                // Manhã: 6 aulas, Tarde/Noite: 7 aulas
                int totalAulas = (turno == "Manhã") ? 6 : 7;

                setState(() {
                  _todasAsTurmas.add(Turma(
                    nome: nomeController.text.toUpperCase(),
                    modalidade: mod,
                    turno: turno,
                    aulas: {
                      "Segunda": List.filled(totalAulas, "-"),
                      "Terça": List.filled(totalAulas, "-"),
                      "Quarta": List.filled(totalAulas, "-"),
                      "Quinta": List.filled(totalAulas, "-"),
                      "Sexta": List.filled(totalAulas, "-"),
                    },
                  ));
                });
                
                // Salva no banco de dados local imediatamente
                _jsonService.salvarDadosLocais(_todasAsTurmas);
                
                Navigator.pop(context); // Fecha o Dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Turma ${nomeController.text} adicionada!")),
                );
              }
            },
            child: const Text("Cadastrar"),
          ),
        ],
      ),
    ),
  );
}
}