// Ficheiro: lib/features/admin_web/manage_teachers/screens/docente_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../../data/models/docente_model.dart';

class DocenteFormDialog extends StatefulWidget {
  final DocenteModel? docenteExistente;

  const DocenteFormDialog({Key? key, this.docenteExistente}) : super(key: key);

  @override
  State<DocenteFormDialog> createState() => _DocenteFormDialogState();
}

class _DocenteFormDialogState extends State<DocenteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  
  // NOVO: Conjunto de dias selecionados
  final Set<String> _diasSelecionados = {};

  final List<String> _todosOsDias = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.docenteExistente?.nome ?? '');
    _emailController = TextEditingController(text: widget.docenteExistente?.email ?? '');

    // Se for edição, carrega os dias que já estavam salvos no Firebase
    if (widget.docenteExistente != null) {
      _diasSelecionados.addAll(widget.docenteExistente!.diasEscala);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.docenteExistente == null ? 'Novo Docente' : 'Editar Docente'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail (Login do App)',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 20),

                // SEÇÃO DE SELEÇÃO DOS DIAS
                const Text(
                  'Dias de Atuação na Escala:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Wrap com Filtros estilo "Chips" clicáveis
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _todosOsDias.map((dia) {
                    final isSelected = _diasSelecionados.contains(dia);
                    return FilterChip(
                      label: Text(dia),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1E5BB2).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF1E5BB2),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _diasSelecionados.add(dia);
                          } else {
                            _diasSelecionados.remove(dia);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final dadosFormulario = {
                'nome': _nomeController.text,
                'email': _emailController.text,
                'diasEscala': _diasSelecionados.toList(), // NOVO: Retorna os dias
              };
              Navigator.of(context).pop(dadosFormulario); 
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5BB2)),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}