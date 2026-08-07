import 'package:flutter/material.dart';
import '../models/turma_model.dart';
import '../services/json_service.dart';

class SetupWizard extends StatefulWidget {
  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  int _passoAtual = 0;
  final JsonService _service = JsonService();
  
  // 1. Dados de Salas
  final List<String> _salas = [];
  final TextEditingController _salaController = TextEditingController();

  // 2. Dados de Turmas
  final List<Turma> _turmas = [];
  final TextEditingController _turmaController = TextEditingController();
  String _modalidadeSelecionada = "Ensino Médio";
  String _turnoSelecionado = "Manhã";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CONFIGURAÇÃO DA ESCOLA"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _passoAtual,
        onStepContinue: () {
          if (_passoAtual < 2) {
            setState(() => _passoAtual++);
          } else {
            _finalizarESalvar();
          }
        },
        onStepCancel: () {
          if (_passoAtual > 0) {
            setState(() => _passoAtual--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_passoAtual == 2 ? "SALVAR TUDO" : "PRÓXIMO PASSO"),
                ),
                const SizedBox(width: 10),
                if (_passoAtual > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("VOLTAR"),
                  ),
              ],
            ),
          );
        },
        steps: [
          // PASSO 1: CRIAR SALAS FÍSICAS
          Step(
            isActive: _passoAtual >= 0,
            title: const Text("1. Cadastrar Salas de Aula", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quais são as salas físicas e laboratórios da escola?"),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _salaController,
                        decoration: const InputDecoration(hintText: "Ex: A1, LAB 02, B3, E.F."),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
                      onPressed: () {
                        if (_salaController.text.isNotEmpty) {
                          setState(() => _salas.add(_salaController.text.toUpperCase()));
                          _salaController.clear();
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _salas.map((s) => Chip(
                    label: Text(s),
                    onDeleted: () => setState(() => _salas.remove(s)),
                  )).toList(),
                )
              ],
            ),
          ),

          // PASSO 2: CRIAR TURMAS COM MODALIDADE E TURNO
          Step(
            isActive: _passoAtual >= 1,
            title: const Text("2. Cadastrar Turmas e Períodos", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _turmaController,
                  decoration: const InputDecoration(labelText: "Nome da Turma (Ex: 1º ADM)"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _modalidadeSelecionada,
                        decoration: const InputDecoration(labelText: "Modalidade"),
                        items: ["Ensino Médio", "Modular"].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setState(() => _modalidadeSelecionada = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _turnoSelecionado,
                        decoration: const InputDecoration(labelText: "Turno"),
                        items: ["Manhã", "Tarde", "Noite"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setState(() => _turnoSelecionado = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("ADICIONAR TURMA"),
                  onPressed: () {
                    if (_turmaController.text.isNotEmpty) {
                      setState(() {
                        _turmas.add(Turma(
                          nome: _turmaController.text.toUpperCase(),
                          modalidade: _modalidadeSelecionada,
                          turno: _turnoSelecionado,
                          aulas: {
                            "Segunda": List.filled(6, "-"),
                            "Terça": List.filled(6, "-"),
                            "Quarta": List.filled(6, "-"),
                            "Quinta": List.filled(6, "-"),
                            "Sexta": List.filled(6, "-"),
                          }, // 6 aulas em branco para começar
                        ));
                        _turmaController.clear();
                      });
                    }
                  },
                ),
                const Divider(),
                ..._turmas.map((t) => ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(t.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${t.modalidade} - ${t.turno}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _turmas.remove(t)),
                  ),
                )).toList()
              ],
            ),
          ),

          // PASSO 3: CONCLUSÃO
          Step(
            isActive: _passoAtual >= 2,
            title: const Text("3. Finalizar e Gerar Grade", style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("Ao salvar, o sistema criará o banco de dados. Você será redirecionado para o Painel Administrativo, onde poderá alocar as salas em cada horário."),
          ),
        ],
      ),
    );
  }

  void _finalizarESalvar() async {
    // 1. Salva tudo usando o novo método do serviço
    await _service.salvarBancoCompleto(_salas, _turmas);
    
    // 2. Avisa o usuário e vai para o painel de administração
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Escola configurada com sucesso!")),
    );
    Navigator.pushReplacementNamed(context, '/admin');
  }
}