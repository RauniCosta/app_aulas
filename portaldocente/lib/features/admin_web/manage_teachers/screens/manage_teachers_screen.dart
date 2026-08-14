// Ficheiro: lib/features/admin_web/manage_teachers/screens/manage_teachers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portaldocente/data/models/docente_model.dart';
import '../providers/docente_providers.dart';
import 'docente_form_dialog.dart';

// Trocamos StatelessWidget/StatefulWidget por ConsumerWidget
class ManageTeachersScreen extends ConsumerWidget {
  const ManageTeachersScreen({Key? key}) : super(key: key);

  @override
  // O método build agora recebe um WidgetRef (ref), que é o nosso "controle remoto" do Riverpod
  Widget build(BuildContext context, WidgetRef ref) {
    // Aqui estamos escutando o estado da nossa lista de professores!
    final docentesAsyncValue = ref.watch(docentesListProvider);

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestão de Docentes',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final resultado = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const DocenteFormDialog(),
                  );

                  if (resultado != null) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'A guardar docente e a criar conta de acesso...',
                          ),
                        ),
                      );

                      final novoDocente = DocenteModel(
                        id: '', // Firebase gera o ID automaticamente
                        nome: resultado['nome'],
                        titulo: 'Prof.',
                        email: resultado['email'],
                        telefone: 'Não definido',
                        especialidades: [],
                        fotoUrl: '',
                        diasEscala: List<String>.from(
                          resultado['diasEscala'] ?? [],
                        ),
                      );

                      // Define a senha provisória que o professor usará no primeiro acesso
                      const String senhaProvisoria = '123456';

                      // ✅ CORREÇÃO AQUI: Passamos o docente E a senha provisória!
                      await ref
                          .read(docenteRepositoryProvider)
                          .addDocente(novoDocente, senhaProvisoria);

                      // Atualiza a tabela na tela
                      ref.invalidate(docentesListProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Docente e usuário criados com sucesso! ✅',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao cadastrar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Docente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E5BB2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // --- AQUI ENTRA O PODER DO RIVERPOD (AsyncValue) ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              // O "when" nos obriga a tratar Loading, Error e Data. Nunca mais teremos telas em branco por erro!
              child: docentesAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (error, stackTrace) => Center(
                  child: Text(
                    'Erro ao carregar docentes: $error',
                    style: const TextStyle(color: Color(0xFF61120D)),
                  ),
                ),

                data: (listaDocentes) {
                  if (listaDocentes.isEmpty) {
                    return const Center(
                      child: Text('Nenhum professor cadastrado ainda.'),
                    );
                  }

                  return SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey[50],
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Nome do Docente',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'E-mail',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Dias de Atuação',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Ações',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: listaDocentes.map((docente) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: Text(
                                      docente.nome.isNotEmpty
                                          ? docente.nome[0]
                                          : '?',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(docente.nome),
                                ],
                              ),
                            ),
                            DataCell(Text(docente.email)),
                            DataCell(
                              docente.diasEscala.isEmpty
                                  ? const Text(
                                      'Nenhum dia definido',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 4,
                                      children: docente.diasEscala.map((d) {
                                        final sigla = d
                                            .split('-')[0]
                                            .substring(
                                              0,
                                              3,
                                            ); // Ex: "Seg", "Ter"
                                        return Chip(
                                          label: Text(
                                            sigla,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        );
                                      }).toList(),
                                    ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  // --- BOTÃO EDITAR ---
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      // Abre o modal, mas agora enviando os dados do professor clicado!
                                      final resultado =
                                          await showDialog<
                                            Map<String, dynamic>
                                          >(
                                            context: context,
                                            builder: (context) =>
                                                DocenteFormDialog(
                                                  docenteExistente: docente,
                                                ),
                                          );

                                      if (resultado != null) {
                                        try {
                                          // Recria o modelo com os dados alterados, mantendo o ID original
                                          final docenteAtualizado =
                                              DocenteModel(
                                                id: docente.id,
                                                nome: resultado['nome'],
                                                titulo: docente.titulo,
                                                email: resultado['email'],
                                                telefone: docente.telefone,
                                                especialidades:
                                                    docente.especialidades,
                                                fotoUrl: docente.fotoUrl,
                                              );

                                          // Chama o repositório para atualizar no Firebase
                                          await ref
                                              .read(docenteRepositoryProvider)
                                              .updateDocente(docenteAtualizado);
                                          ref.invalidate(
                                            docentesListProvider,
                                          ); // Recarrega a tabela

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Docente atualizado com sucesso!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao atualizar: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),

                                  // --- BOTÃO EXCLUIR ---
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      // Mostra um alerta de confirmação antes de apagar do banco de dados
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Excluir Docente?'),
                                          content: Text(
                                            'Tem a certeza que deseja excluir o professor ${docente.nome}? Esta ação não pode ser desfeita.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Excluir',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmar == true) {
                                        try {
                                          await ref
                                              .read(docenteRepositoryProvider)
                                              .deleteDocente(docente.id);
                                          ref.invalidate(
                                            docentesListProvider,
                                          ); // Recarrega a tabela

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Docente excluído com sucesso!',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao excluir: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isSelected) {
    return Container(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {},
      ),
    );
  }
}
