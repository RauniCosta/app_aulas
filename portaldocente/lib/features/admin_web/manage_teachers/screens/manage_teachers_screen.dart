// Ficheiro: lib/features/admin_web/manage_teachers/screens/manage_teachers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/docente_providers.dart';
import 'docente_form_dialog.dart';
import '../../../../data/models/docente_model.dart';

class ManageTeachersScreen extends ConsumerWidget {
  const ManageTeachersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docentesAsyncValue = ref.watch(docentesListProvider);

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestão de Docentes',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Cadastre e gira o corpo docente da instituição',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
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
                        const SnackBar(content: Text('A guardar docente...')),
                      );

                      final novoDocente = DocenteModel(
                        id: '',
                        nome: resultado['nome'],
                        sigla: resultado['sigla'], // NOVO: Passando a sigla
                        titulo: 'Prof.',
                        email: resultado['email'],
                        diasEscala: List<String>.from(resultado['diasEscala'] ?? []),
                      );

                      const String senhaProvisoria = '123456';

                      await ref
                          .read(docenteRepositoryProvider)
                          .addDocente(novoDocente, senhaProvisoria);
                      ref.invalidate(docentesListProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Docente criado com sucesso! ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Docente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: docentesAsyncValue.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('Erro ao carregar docentes: $err')),
                  data: (docentes) {
                    if (docentes.isEmpty) {
                      return const Center(
                        child: Text('Nenhum docente cadastrado ainda.'),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Nome',
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
                          rows: docentes.map((docente) {
                            return DataRow(
                              // Adicionar esta linha faz a tabela reagir ao mouse na Web!
                              onSelectChanged: (bool? selected) {},
                              cells: [
                                // NOVO: Exibe a sigla ao lado do nome na tabela!
                                DataCell(Text('${docente.nome} (${docente.sigla})')),
                                DataCell(Text(docente.email)),
                                DataCell(
                                  docente.diasEscala.isEmpty
                                      ? const Text(
                                          'Não definido',
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
                                                .substring(0, 3);
                                            return Chip(
                                              label: Text(
                                                sigla,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            );
                                          }).toList(),
                                        ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
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
                                            final atualizado = DocenteModel(
                                              id: docente.id,
                                              nome: resultado['nome'],
                                              sigla: resultado['sigla'], // NOVO: Atualizando a sigla
                                              email: resultado['email'],
                                              diasEscala: List<String>.from(resultado['diasEscala'] ?? []),
                                            );
                                            await ref.read(docenteRepositoryProvider).updateDocente(atualizado);
                                            ref.invalidate(
                                              docentesListProvider,
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirmar = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text(
                                                'Excluir Docente?',
                                              ),
                                              content: Text(
                                                'Deseja excluir o professor ${docente.nome}?',
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
                                            await ref
                                                .read(docenteRepositoryProvider)
                                                .deleteDocente(docente.id);
                                            ref.invalidate(
                                              docentesListProvider,
                                            );
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
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
