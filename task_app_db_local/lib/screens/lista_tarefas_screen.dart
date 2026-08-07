import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/api_service.dart'; // IMPORTANTE: Importamos o serviço da API
import '../models/tarefa.dart';
import 'form_tarefa_screen.dart';

class ListaTarefasScreen extends StatefulWidget {
  @override
  _ListaTarefasScreenState createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends State<ListaTarefasScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ApiService apiService = ApiService(); // Instância da nossa API
  
  late Future<List<Tarefa>> tarefasLista;
  
  // A "chave mágica" da nossa aula: um booleano que controla a origem dos dados
  bool buscandoDaNuvem = false; 

  @override
  void initState() {
    super.initState();
    atualizarLista();
  }

  // Agora este método é inteligente: ele olha a variável buscandoDaNuvem
  // para decidir de qual fonte de dados vai carregar a lista.
  void atualizarLista() {
    setState(() {
      if (buscandoDaNuvem) {
        tarefasLista = apiService.obterTarefasOnline(); // Puxa da Internet
      } else {
        tarefasLista = dbHelper.obterTarefas(); // Puxa do SQLite
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Mudamos o título e a cor dinamicamente para o aluno perceber a mudança
        title: Text(buscandoDaNuvem ? 'Tarefas na Nuvem ☁️' : 'Minhas Tarefas (Local) 📱'),
        backgroundColor: buscandoDaNuvem ? Colors.deepPurple : Colors.blue,
        actions: [
          // Botão que alterna entre Local e Online
          IconButton(
            icon: Icon(buscandoDaNuvem ? Icons.cloud_off : Icons.cloud),
            tooltip: 'Alternar Nuvem/Local',
            onPressed: () {
              setState(() {
                buscandoDaNuvem = !buscandoDaNuvem; // Inverte o valor (True vira False, e vice-versa)
                atualizarLista(); // Recarrega a tela
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: tarefasLista,
        builder: (context, snapshot) {
          // O FutureBuilder continua o mesmo! Ele não se importa de onde o dado vem.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma tarefa encontrada.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Tarefa tarefa = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    tarefa.concluida == 1 ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: tarefa.concluida == 1 ? Colors.green : Colors.grey,
                  ),
                  title: Text(tarefa.titulo),
                  subtitle: Text(tarefa.descricao),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      if (buscandoDaNuvem) {
                        // Aviso pedagógico: API Fake não deleta de verdade
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Aviso: API Fake apenas simula a exclusão!')),
                        );
                      } else {
                        // Deleta do SQLite
                        await dbHelper.deletarTarefa(tarefa.id!);
                        atualizarLista();
                      }
                    },
                  ),
                  onTap: () async {
                     if (buscandoDaNuvem) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edição desabilitada no modo Nuvem nesta aula.')),
                        );
                     } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormTarefaScreen(tarefa: tarefa),
                          ),
                        );
                        atualizarLista();
                     }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buscandoDaNuvem ? Colors.deepPurple : Colors.blue,
        child: Icon(Icons.add),
        onPressed: () async {
          if (buscandoDaNuvem) {
            // Demonstra o método POST simulado da nossa API
            Tarefa tarefaFake = Tarefa(titulo: "Nova Tarefa Nuvem", descricao: "Post pelo App!");
            await apiService.inserirTarefaOnline(tarefaFake);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Post enviado para a API! Olhe o terminal (Console).')),
            );
          } else {
            // Vai para a tela de cadastro local
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormTarefaScreen()),
            );
            atualizarLista();
          }
        },
      ),
    );
  }
}