// Ficheiro: lib/features/admin_web/manage_courses/screens/turma_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../../data/models/turma_model.dart';

class TurmaFormDialog extends StatefulWidget {
  final String cursoId;
  final TurmaModel? turmaExistente; // NOVO: Permite receber os dados para edição

  const TurmaFormDialog({Key? key, required this.cursoId, this.turmaExistente}) : super(key: key);

  @override
  State<TurmaFormDialog> createState() => _TurmaFormDialogState();
}

class _TurmaFormDialogState extends State<TurmaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  String _periodoSelecionado = 'Manhã';
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    // Preenche com os dados da turma se for uma edição
    _nomeController = TextEditingController(text: widget.turmaExistente?.nome ?? '');
    
    if (widget.turmaExistente != null) {
      _periodoSelecionado = widget.turmaExistente!.periodo;
      _dataInicio = widget.turmaExistente!.dataInicio;
      _dataFim = widget.turmaExistente!.dataFim;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? (_dataInicio ?? DateTime.now()) : (_dataFim ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.turmaExistente == null ? 'Nova Turma' : 'Editar Turma'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Identificador/Nome da Turma',
                  hintText: 'Ex: Turma A, 2026/1',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _periodoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Período / Turno',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                items: ['Manhã', 'Tarde', 'Noite', 'Integral']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _periodoSelecionado = val);
                },
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(context, true),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _dataInicio == null
                            ? 'Data Início'
                            : '${_dataInicio!.day.toString().padLeft(2, '0')}/${_dataInicio!.month.toString().padLeft(2, '0')}/${_dataInicio!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(context, false),
                      icon: const Icon(Icons.event, size: 18),
                      label: Text(
                        _dataFim == null
                            ? 'Data Fim'
                            : '${_dataFim!.day.toString().padLeft(2, '0')}/${_dataFim!.month.toString().padLeft(2, '0')}/${_dataFim!.year}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_dataInicio == null || _dataFim == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione as datas de início e fim da turma.')),
                );
                return;
              }

              // Se for edição, mantém o ID original. Se for nova, envia vazio.
              final turmaPronta = TurmaModel(
                id: widget.turmaExistente?.id ?? '', 
                cursoId: widget.cursoId,
                nome: _nomeController.text.trim(),
                dataInicio: _dataInicio!,
                dataFim: _dataFim!,
                periodo: _periodoSelecionado,
              );

              Navigator.pop(context, turmaPronta);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57)),
          child: const Text('Salvar Turma'),
        ),
      ],
    );
  }
}