// Ficheiro: lib/features/admin_web/manage_courses/screens/curso_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../../data/models/curso_model.dart';

class CursoFormDialog extends StatefulWidget {
  final CursoModel?
  cursoExistente; // Permite usar o mesmo modal para Criar e Editar

  const CursoFormDialog({Key? key, this.cursoExistente}) : super(key: key);

  @override
  State<CursoFormDialog> createState() => _CursoFormDialogState();
}

class _CursoFormDialogState extends State<CursoFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _siglaController;
  late TextEditingController _cargaHorariaController;
  String _modalidadeSelecionada = 'Habilitação Técnica'; // Valor por defeito

  // Opções baseadas nos Planos de Oferta que analisámos
  final List<String> _modalidades = [
    'Habilitação Técnica',
    'Aperfeiçoamento',
    'Qualificação Profissional',
    'Cursos Livres',
  ];

  @override
  void initState() {
    super.initState();
    // Preenche os dados se for uma edição
    _nomeController = TextEditingController(
      text: widget.cursoExistente?.nome ?? '',
    );
    // CORREÇÃO: Faltava inicializar a sigla aqui!
    _siglaController = TextEditingController(text: widget.cursoExistente?.sigla ?? '');

    // Exemplo para o Curso (adapte para a UC usando widget.ucExistente)
    _cargaHorariaController = TextEditingController(
      text: widget.cursoExistente != null
          ? widget.cursoExistente!.cargaHorariaTotal.toString()
          : '',
    );

    if (widget.cursoExistente != null &&
        _modalidades.contains(widget.cursoExistente!.modalidade)) {
      _modalidadeSelecionada = widget.cursoExistente!.modalidade;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _siglaController.dispose();
    _cargaHorariaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.cursoExistente == null ? 'Novo Curso' : 'Editar Curso',
      ),
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
                  labelText: 'Nome do Curso',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _siglaController,
                maxLength:
                    4, // Permite siglas como "TDS" (Tec. Desenv. Sistemas)
                textCapitalization:
                    TextCapitalization.characters, // Força as letras maiúsculas
                decoration: const InputDecoration(
                  labelText: 'Sigla',
                  prefixIcon: Icon(Icons.short_text),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Modalidade',
                        border: OutlineInputBorder(),
                      ),
                      value: _modalidadeSelecionada,
                      items: _modalidades.map((String mod) {
                        return DropdownMenuItem(value: mod, child: Text(mod));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _modalidadeSelecionada = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cargaHorariaController,
                      decoration: const InputDecoration(
                        labelText: 'Horas Totais',
                        prefixIcon: Icon(Icons.timer),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        if (int.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final cursoPronto = CursoModel(
                id: widget.cursoExistente?.id ?? '',
                nome: _nomeController.text.trim(),
                // CORREÇÃO: Agora capturamos a sigla e forçamos para maiúsculas!
                sigla: _siglaController.text.trim().toUpperCase(),
                modalidade: _modalidadeSelecionada,
                cargaHorariaTotal: int.parse(
                  _cargaHorariaController.text.trim(),
                ),
                ativo: true,
              );
              Navigator.of(context).pop(cursoPronto);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8B57),
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
