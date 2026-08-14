// Ficheiro: lib/features/admin_web/manage_courses/screens/manage_courses_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portaldocente/data/models/curso_model.dart';
import 'package:portaldocente/features/admin_web/manage_courses/screens/curso_form_dialog.dart';
import '../providers/curso_providers.dart';

class ManageCoursesScreen extends ConsumerWidget {
  const ManageCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsyncValue = ref.watch(cursosListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // (Imagina aqui o Menu Lateral que já criámos antes)
          const SizedBox(width: 250, child: Placeholder()),

          // --- ÁREA PRINCIPAL ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cursos e Unidades Curriculares',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // ... dentro de manage_courses_screen.dart
                      ElevatedButton.icon(
                        onPressed: () async {
                          // 1. Abre o Modal e espera pelo resultado
                          final novoCurso = await showDialog<CursoModel>(
                            context: context,
                            builder: (context) => const CursoFormDialog(),
                          );

                          // 2. Se o coordenador clicou em "Salvar" (e não em Cancelar)
                          if (novoCurso != null) {
                            try {
                              // Mostra o feedback de carregamento
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('A guardar curso...'),
                                ),
                              );

                              // 3. Grava no Firebase usando o Repositório
                              await ref
                                  .read(cursoRepositoryProvider)
                                  .addCurso(novoCurso);

                              // 4. Diz ao Riverpod para recarregar a lista da UI
                              ref.invalidate(cursosListProvider);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Curso criado com sucesso! ✅'),
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
                        label: const Text('Novo Curso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E5BB2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // LISTA EXPANSÍVEL DE CURSOS
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: cursosAsyncValue.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text('Erro: $err'),
                        data: (cursos) {
                          return ListView.builder(
                            itemCount: cursos.length,
                            itemBuilder: (context, index) {
                              final curso = cursos[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                // O MÁGICO EXPANSION TILE
                                child: ExpansionTile(
                                  title: Text(
                                    curso.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${curso.modalidade} • ${curso.cargaHorariaTotal}h totais',
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(
                                      0xFF1E5BB2,
                                    ).withOpacity(0.1),
                                    child: const Icon(
                                      Icons.school,
                                      color: Color(0xFF1E5BB2),
                                    ),
                                  ),
                                  // O QUE APARECE QUANDO EXPANDIMOS
                                  children: [
                                    Container(
                                      color: Colors.grey.shade50,
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Unidades Curriculares (UCs)',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              TextButton.icon(
                                                onPressed: () {
                                                  /* Adicionar nova UC a este curso */
                                                },
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                label: const Text(
                                                  'Adicionar UC',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          // CONSUMER isolado para buscar as UCs apenas quando expandido
                                          Consumer(
                                            builder: (context, ref, child) {
                                              final ucsAsyncValue = ref.watch(
                                                ucsPorCursoProvider(curso.id),
                                              );

                                              return ucsAsyncValue.when(
                                                loading: () => const Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                                error: (err, stack) =>
                                                    Text('Erro: $err'),
                                                data: (ucs) {
                                                  if (ucs.isEmpty)
                                                    return const Text(
                                                      'Nenhuma UC registada neste curso.',
                                                    );

                                                  return Column(
                                                    children: ucs
                                                        .map(
                                                          (uc) => ListTile(
                                                            title: Text(
                                                              uc.nome,
                                                            ),
                                                            subtitle: Text(
                                                              'Módulo ${uc.moduloOuSemestre}',
                                                            ),
                                                            trailing: Text(
                                                              '${uc.cargaHoraria}h',
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
