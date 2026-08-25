// Ficheiro: lib/features/admin_web/manage_courses/screens/uc_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../../data/models/unidade_curricular_model.dart';

class UCFormDialog extends StatefulWidget {
  final String cursoId;
  final UnidadeCurricularModel? ucExistente;

  const UCFormDialog({Key? key, required this.cursoId, this.ucExistente}) : super(key: key);

  @override
  State<UCFormDialog> createState() => _UCFormDialogState();
}

class _UCFormDialogState extends State<UCFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _siglaController; // NOVO CONTROLLER
  late TextEditingController _cargaHorariaController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.ucExistente?.nome ?? '');
    _siglaController = TextEditingController(text: widget.ucExistente?.sigla ?? ''); // NOVO
    _cargaHorariaController = TextEditingController(
      text: widget.ucExistente != null ? widget.ucExistente!.cargaHoraria.toString() : ''
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _siglaController.dispose(); // NOVO
    _cargaHorariaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ucExistente == null ? 'Nova Unidade Curricular' : 'Editar Unidade Curricular'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina / UC',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),

              // NOVO: CAMPO DA SIGLA DA UC
              TextFormField(
                controller: _siglaController,
                maxLength: 4, 
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Sigla (Ex: BD1, LOG)',
                  prefixIcon: Icon(Icons.short_text),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _cargaHorariaController,
                decoration: const InputDecoration(
                  labelText: 'Carga Horária (Horas)',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obrigatório';
                  if (int.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
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
              final ucPronta = UnidadeCurricularModel(
                id: widget.ucExistente?.id ?? '', 
                cursoId: widget.cursoId,
                nome: _nomeController.text.trim(),
                sigla: _siglaController.text.trim().toUpperCase(), // SALVANDO A SIGLA
                cargaHoraria: int.parse(_cargaHorariaController.text.trim()),
                moduloOuSemestre: widget.ucExistente?.moduloOuSemestre ?? 'Módulo 1',
              );
              Navigator.pop(context, ucPronta);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57)),
          child: const Text('Salvar UC'),
        ),
      ],
    );
  }
}