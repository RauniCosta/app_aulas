// Ficheiro: lib/features/admin_web/scale_builder/screens/scale_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../manage_courses/providers/curso_providers.dart';
import '../../manage_teachers/providers/docente_providers.dart';
import '../../../../data/models/escala_model.dart';
import '../../../../data/models/curso_model.dart';
import '../../../../data/models/turma_model.dart';
import '../../../../data/repositories/escala_repository.dart';

final escalaRepositoryProvider = Provider((ref) => EscalaRepository());

final cursoObjetoSelecionadoProvider = StateProvider.autoDispose<CursoModel?>((ref) => null);
final turmaObjetoSelecionadaProvider = StateProvider.autoDispose<TurmaModel?>((ref) => null); // AGORA É O OBJETO TURMA
final ucSelecionadaProvider = StateProvider.autoDispose<String?>((ref) => null);
final diaDaSemanaProvider = StateProvider.autoDispose<String>((ref) => 'Segunda-feira');
final turnoSelecionadoProvider = StateProvider.autoDispose<String>((ref) => 'Manhã (08:00 - 12:30)');
final docentesSelecionadosProvider = StateProvider.autoDispose<Set<String>>((ref) => {});

class ScaleBuilderScreen extends ConsumerWidget {
  const ScaleBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursoObjeto = ref.watch(cursoObjetoSelecionadoProvider);
    final turmaObjeto = ref.watch(turmaObjetoSelecionadaProvider);
    final ucSelecionada = ref.watch(ucSelecionadaProvider);
    final diaDaSemana = ref.watch(diaDaSemanaProvider);
    final turnoSelecionado = ref.watch(turnoSelecionadoProvider);
    final docentesSelecionados = ref.watch(docentesSelecionadosProvider);
    
    final cursosAsync = ref.watch(cursosListProvider);
    final docentesAsync = ref.watch(docentesListProvider);

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Montagem de Escala', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('Atribua disciplinas e horários aos professores e turmas cadastradas', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- FORMULÁRIO DE SELEÇÃO ---
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. Curso, Turma e Disciplina', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          
                          // 1. SELEÇÃO DO CURSO
                          cursosAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (e, s) => Text('Erro: $e'),
                            data: (cursos) => DropdownButtonFormField<CursoModel>(
                              decoration: const InputDecoration(labelText: 'Curso', border: OutlineInputBorder()),
                              value: cursoObjeto,
                              items: cursos.map((c) => DropdownMenuItem(value: c, child: Text(c.nome))).toList(),
                              onChanged: (val) {
                                ref.read(cursoObjetoSelecionadoProvider.notifier).state = val;
                                ref.read(turmaObjetoSelecionadaProvider.notifier).state = null; // Reseta turma
                                ref.read(ucSelecionadaProvider.notifier).state = null; // Reseta UC
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          // 2. SELEÇÃO DA TURMA (DINÂMICA POR CURSO)
                          if (cursoObjeto == null)
                            const TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Selecione um curso primeiro para ver as Turmas',
                                border: OutlineInputBorder(),
                              ),
                            )
                          else
                            Consumer(
                              builder: (context, ref, child) {
                                final turmasAsync = ref.watch(turmasPorCursoProvider(cursoObjeto.id));

                                return turmasAsync.when(
                                  loading: () => const LinearProgressIndicator(),
                                  error: (e, s) => Text('Erro ao carregar Turmas: $e'),
                                  data: (turmas) {
                                    if (turmas.isEmpty) {
                                      return const Text(
                                        'Nenhuma Turma cadastrada para este curso. Cadastre Turmas no menu "Cursos e UCs".',
                                        style: TextStyle(color: Colors.orange, fontSize: 13),
                                      );
                                    }
                                    return DropdownButtonFormField<TurmaModel>(
                                      decoration: const InputDecoration(
                                        labelText: 'Turma (Início/Fim e Período)',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: turmaObjeto,
                                      items: turmas.map((t) {
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(t.periodoFormatado),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        ref.read(turmaObjetoSelecionadaProvider.notifier).state = val;
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: 15),

                          // 3. SELEÇÃO DA UC (ORDENADA ALFABETICAMENTE)
                          if (cursoObjeto == null)
                            const SizedBox.shrink()
                          else
                            Consumer(
                              builder: (context, ref, child) {
                                final ucsAsync = ref.watch(ucsPorCursoProvider(cursoObjeto.id));

                                return ucsAsync.when(
                                  loading: () => const LinearProgressIndicator(),
                                  error: (e, s) => Text('Erro ao carregar UCs: $e'),
                                  data: (ucs) {
                                    if (ucs.isEmpty) {
                                      return const Text(
                                        'Nenhuma UC cadastrada para este curso.',
                                        style: TextStyle(color: Colors.orange, fontSize: 13),
                                      );
                                    }
                                    return DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Unidade Curricular (UC) - Ordem Alfabética',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: ucSelecionada,
                                      items: ucs.map((uc) {
                                        return DropdownMenuItem(
                                          value: uc.nome,
                                          child: Text('${uc.nome} (${uc.cargaHoraria}h)'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        ref.read(ucSelecionadaProvider.notifier).state = val;
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                          const Divider(height: 35),
                          const Text('2. Horário e Docentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Dia da Semana', border: OutlineInputBorder()),
                                  value: diaDaSemana,
                                  items: ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado']
                                      .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                  onChanged: (val) => ref.read(diaDaSemanaProvider.notifier).state = val!,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Turno/Bloco', border: OutlineInputBorder()),
                                  value: turnoSelecionado,
                                  items: ['Manhã (08:00 - 12:30)', 'Tarde (13:30 - 17:30)', 'Noite (18:30 - 22:30)']
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                  onChanged: (val) => ref.read(turnoSelecionadoProvider.notifier).state = val!,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          const Text('Docentes Alocados:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: docentesAsync.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (e, s) => const Text('Erro ao carregar docentes'),
                              data: (docentes) => ListView.builder(
                                itemCount: docentes.length,
                                itemBuilder: (context, index) {
                                  final docente = docentes[index];
                                  final isSelected = docentesSelecionados.contains(docente.nome);
                                  return CheckboxListTile(
                                    dense: true,
                                    title: Text(docente.nome),
                                    subtitle: Text('Disponível: ${docente.diasEscala.join(", ")}'),
                                    value: isSelected,
                                    activeColor: const Color(0xFF1E5BB2),
                                    onChanged: (bool? checked) {
                                      final setNotifier = ref.read(docentesSelecionadosProvider.notifier);
                                      if (checked == true) {
                                        setNotifier.state = {...docentesSelecionados, docente.nome};
                                      } else {
                                        setNotifier.state = {...docentesSelecionados}..remove(docente.nome);
                                      }
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
                ),
                
                const SizedBox(width: 30),

                // --- RESUMO DA ESCALA ---
                Expanded(
                  flex: 1,
                  child: Card(
                    color: const Color(0xFF1E5BB2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resumo da Aula', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Divider(color: Colors.white54, height: 25),
                          _buildResumoItem('Curso:', cursoObjeto?.nome ?? 'Não selecionado'),
                          _buildResumoItem('Turma:', turmaObjeto != null ? '${turmaObjeto.nome} (${turmaObjeto.periodo})' : 'Não selecionada'),
                          _buildResumoItem('Datas:', turmaObjeto != null ? '${turmaObjeto.dataInicio.day}/${turmaObjeto.dataInicio.month} até ${turmaObjeto.dataFim.day}/${turmaObjeto.dataFim.month}/${turmaObjeto.dataFim.year}' : 'A definir'),
                          _buildResumoItem('Disciplina (UC):', ucSelecionada ?? 'Não selecionada'),
                          _buildResumoItem('Dia e Turno:', '$diaDaSemana | $turnoSelecionado'),
                          _buildResumoItem('Professores:', '${docentesSelecionados.length} selecionado(s)'),
                          
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1E5BB2),
                              ),
                              onPressed: (docentesSelecionados.isEmpty || cursoObjeto == null || turmaObjeto == null || ucSelecionada == null)
                                  ? null 
                                  : () async {
                                      try {
                                        final novaEscala = EscalaModel(
                                          id: '',
                                          idCurso: cursoObjeto.nome,
                                          turma: turmaObjeto.nome,
                                          nomeUnidadeCurricular: ucSelecionada,
                                          idDocentes: docentesSelecionados.toList(),
                                          diaDaSemana: diaDaSemana,
                                          blocoTurno: turnoSelecionado,
                                          sala: 'A Definir',
                                        );

                                        await ref.read(escalaRepositoryProvider).addEscala(novaEscala);

                                        ref.invalidate(cursoObjetoSelecionadoProvider);
                                        ref.invalidate(turmaObjetoSelecionadaProvider);
                                        ref.invalidate(ucSelecionadaProvider);
                                        ref.invalidate(docentesSelecionadosProvider);

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Escala Guardada com Sucesso! ✅'), backgroundColor: Colors.green)
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro ao guardar: $e'), backgroundColor: Colors.red)
                                          );
                                        }
                                      }
                                    },
                              child: const Text('Guardar Escala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}