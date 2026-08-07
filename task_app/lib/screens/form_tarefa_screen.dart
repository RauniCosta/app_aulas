import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class FormTarefaScreen extends StatefulWidget {
  final Tarefa? tarefa; // Se for nulo = Nova, se tiver dados = Edição

  const FormTarefaScreen({super.key, this.tarefa});

  @override
  _FormTarefaScreenState createState() => _FormTarefaScreenState();
}

class _FormTarefaScreenState extends State<FormTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      _tituloController.text = widget.tarefa!.titulo;
      _descricaoController.text = widget.tarefa!.descricao;
    }
  }

  void _salvarTarefa() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.tarefa == null) {
          Tarefa novaTarefa = Tarefa(
            titulo: _tituloController.text,
            descricao: _descricaoController.text,
          );
          await dbHelper.inserirTarefa(novaTarefa);
          print("Tarefa inserida com sucesso!"); // Log de sucesso
        } else {
          // ... (código de atualização)
        }
        Navigator.pop(context); 
      } catch (e) {
        // Se der erro no banco, vai aparecer no terminal!
        print("ERRO AO SALVAR NO BANCO: $e"); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarTarefa,
                child: Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}