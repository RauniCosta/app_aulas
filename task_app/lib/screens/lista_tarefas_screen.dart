import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'form_tarefa_screen.dart';

class ListaTarefasScreen extends StatefulWidget {
  @override
  _ListaTarefasScreenState createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends State<ListaTarefasScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Tarefa>> tarefasLista;

  @override
  void initState() {
    super.initState();
    atualizarLista();
  }

  void atualizarLista() {
    setState(() {
      tarefasLista = dbHelper.obterTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Tarefas (Local)')),
      body: FutureBuilder<List<Tarefa>>(
        future: tarefasLista,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar tarefas.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma tarefa cadastrada.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Tarefa tarefa = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(tarefa.titulo),
                  subtitle: Text(tarefa.descricao),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await dbHelper.deletarTarefa(tarefa.id!);
                      atualizarLista();
                    },
                  ),
                  onTap: () async {
                    // Vai para a tela de edição
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormTarefaScreen(tarefa: tarefa),
                      ),
                    );
                    atualizarLista();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Vai para a tela de cadastro
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormTarefaScreen()),
          );
          atualizarLista(); // Atualiza após voltar da tela
        },
      ),
    );
  }
}