// Ficheiro: lib/features/admin_web/manage_courses/screens/manage_courses_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/curso_providers.dart';
import 'curso_form_dialog.dart';
import 'uc_form_dialog.dart';
import 'turma_form_dialog.dart';
//import 'pdf_import_dialog.txt'
import 'csv_import_dialog.dart';
import '../../../../data/models/curso_model.dart';
import '../../../../data/models/unidade_curricular_model.dart';
import '../../../../data/models/turma_model.dart';

class ManageCoursesScreen extends ConsumerWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsync = ref.watch(cursosListProvider);

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
                    'Gestão de Cursos, Turmas e UCs',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Organize os cursos, turmas ativas e disciplinas ofertadas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final novoCurso = await showDialog<CursoModel>(
                    context: context,
                    builder: (context) => const CursoFormDialog(),
                  );

                  if (novoCurso != null) {
                    try {
                      await ref
                          .read(cursoRepositoryProvider)
                          .addCurso(novoCurso);
                      ref.invalidate(cursosListProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Curso criado com sucesso! ✅'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar curso: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Curso'),
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

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: cursosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('Erro ao carregar cursos: $err')),
                  data: (cursos) {
                    if (cursos.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum curso cadastrado ainda. Clique em "Novo Curso" acima!',
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: cursos.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final curso = cursos[index];
                        return ExpansionTile(
                          leading: const Icon(
                            Icons.school,
                            color: Color(0xFF1E5BB2),
                          ),
                          title: Text(
                            curso.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Modalidade: ${curso.modalidade} | Carga Horária: ${curso.cargaHorariaTotal}h',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final cursoEditado =
                                      await showDialog<CursoModel>(
                                        context: context,
                                        builder: (context) => CursoFormDialog(
                                          cursoExistente: curso,
                                        ),
                                      );
                                  if (cursoEditado != null) {
                                    await ref
                                        .read(cursoRepositoryProvider)
                                        .updateCurso(cursoEditado);
                                    ref.invalidate(cursosListProvider);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Excluir Curso?'),
                                      content: Text(
                                        'Deseja excluir o curso ${curso.nome}?',
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
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await ref
                                        .read(cursoRepositoryProvider)
                                        .deleteCurso(curso.id);
                                    ref.invalidate(cursosListProvider);
                                  }
                                },
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- SEÇÃO 1: TURMAS DO CURSO ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Turmas Cadastradas:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final novaTurma =
                                              await showDialog<TurmaModel>(
                                                context: context,
                                                builder: (context) =>
                                                    TurmaFormDialog(
                                                      cursoId: curso.id,
                                                    ),
                                              );

                                          if (novaTurma != null) {
                                            await ref
                                                .read(cursoRepositoryProvider)
                                                .addTurma(novaTurma);
                                            ref.invalidate(
                                              turmasPorCursoProvider(curso.id),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.group_add,
                                          size: 18,
                                        ),
                                        label: const Text('Criar Turma'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1E5BB2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Lista de Turmas do Curso
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final turmasAsync = ref.watch(
                                        turmasPorCursoProvider(curso.id),
                                      );

                                      return turmasAsync.when(
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (err, stack) => Text(
                                          'Erro ao carregar turmas: $err',
                                        ),
                                        data: (turmas) {
                                          if (turmas.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Text(
                                                'Nenhuma turma cadastrada ainda para este curso.',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            );
                                          }
                                          return Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: turmas.map((t) {
                                              return Chip(
                                                avatar: const Icon(
                                                  Icons.group,
                                                  size: 16,
                                                  color: Color(0xFF1E5BB2),
                                                ),
                                                label: Text(
                                                  t.periodoFormatado,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.blue.shade50,
                                              );
                                            }).toList(),
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  const Divider(height: 30),

                                  // --- SEÇÃO 2: UNIDADES CURRICULARES (UCs) ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Unidades Curriculares (UCs):',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final novaUC =
                                                  await showDialog<
                                                    UnidadeCurricularModel
                                                  >(
                                                    context: context,
                                                    builder: (context) =>
                                                        UCFormDialog(
                                                          cursoId: curso.id,
                                                        ),
                                                  );

                                              if (novaUC != null) {
                                                await ref
                                                    .read(
                                                      cursoRepositoryProvider,
                                                    )
                                                    .addUC(novaUC);
                                                ref.invalidate(
                                                  ucsPorCursoProvider(curso.id),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              size: 18,
                                            ),
                                            label: const Text('Adicionar UC'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFF1E5BB2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final List<
                                                UnidadeCurricularModel
                                              >?
                                              ucsExtraidas =
                                                  await showDialog<
                                                    List<UnidadeCurricularModel>
                                                  >(
                                                    context: context,
                                                    builder: (context) =>
                                                        CsvImportDialog(
                                                          cursoId: curso.id,
                                                        ), // <--- CHAMADA NOVA AQUI
                                                  );

                                              if (ucsExtraidas != null &&
                                                  ucsExtraidas.isNotEmpty) {
                                                for (var uc in ucsExtraidas) {
                                                  await ref
                                                      .read(
                                                        cursoRepositoryProvider,
                                                      )
                                                      .addUC(uc);
                                                }
                                                ref.invalidate(
                                                  ucsPorCursoProvider(curso.id),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.table_chart,
                                              size: 18,
                                              color: Colors.orange,
                                            ), // Mudei o ícone para table_chart
                                            label: const Text(
                                              'Importar CSV',
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),

                                  // Lista de UCs
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final ucsAsync = ref.watch(
                                        ucsPorCursoProvider(curso.id),
                                      );

                                      return ucsAsync.when(
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (err, stack) =>
                                            Text('Erro ao carregar UCs: $err'),
                                        data: (ucs) {
                                          if (ucs.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              child: Text(
                                                'Nenhuma UC cadastrada ainda.',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            );
                                          }
                                          return Column(
                                            children: ucs.map((uc) {
                                              return ListTile(
                                                dense: true,
                                                leading: const Icon(
                                                  Icons.book,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                                title: Text(
                                                  uc.nome,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  'Carga Horária: ${uc.cargaHoraria}h',
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                  onPressed: () async {
                                                    await ref
                                                        .read(
                                                          cursoRepositoryProvider,
                                                        )
                                                        .deleteUC(uc.id);
                                                    ref.invalidate(
                                                      ucsPorCursoProvider(
                                                        curso.id,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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
