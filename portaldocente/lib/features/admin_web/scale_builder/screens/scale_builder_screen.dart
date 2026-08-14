// Ficheiro: lib/features/admin_web/scale_builder/screens/scale_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../manage_courses/providers/curso_providers.dart';
import '../../manage_teachers/providers/docente_providers.dart';
import '../../../../data/models/escala_model.dart';
import '../../../../data/repositories/escala_repository.dart';

final escalaRepositoryProvider = Provider((ref) => EscalaRepository());
final cursoSelecionadoProvider = StateProvider<String?>((ref) => null);
final ucSelecionadaProvider = StateProvider<String?>((ref) => null);
final diaDaSemanaProvider = StateProvider<String>((ref) => 'Segunda-feira');
final turnoSelecionadoProvider = StateProvider<String>((ref) => 'Manhã (08:00 - 12:30)');
final docentesSelecionadosProvider = StateProvider<Set<String>>((ref) => {});

class ScaleBuilderScreen extends ConsumerWidget {
  const ScaleBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursoSelecionado = ref.watch(cursoSelecionadoProvider);
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
          const Text('Atribua disciplinas e horários aos professores', style: TextStyle(color: Colors.grey)),
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
                          const Text('1. Curso e Disciplina', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          
                          cursosAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (e, s) => Text('Erro ao carregar cursos: $e'),
                            data: (cursos) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Curso', border: OutlineInputBorder()),
                              value: cursoSelecionado,
                              items: cursos.map((c) => DropdownMenuItem(value: c.nome, child: Text(c.nome))).toList(),
                              onChanged: (val) {
                                ref.read(cursoSelecionadoProvider.notifier).state = val;
                                ref.read(ucSelecionadaProvider.notifier).state = null; 
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Nome da Unidade Curricular (UC)', border: OutlineInputBorder()),
                            onChanged: (val) => ref.read(ucSelecionadaProvider.notifier).state = val,
                          ),

                          const Divider(height: 40),
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
                          const SizedBox(height: 20),

                          const Text('Docentes Alocados:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
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
                                    title: Text(docente.nome),
                                    subtitle: Text(docente.diasEscala.join(', ')),
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
                          const Divider(color: Colors.white54, height: 30),
                          _buildResumoItem('Curso:', cursoSelecionado ?? 'Não selecionado'),
                          _buildResumoItem('Disciplina:', ucSelecionada ?? 'Não informada'),
                          _buildResumoItem('Dia:', diaDaSemana),
                          _buildResumoItem('Turno:', turnoSelecionado),
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
                              onPressed: (docentesSelecionados.isEmpty || cursoSelecionado == null || ucSelecionada == null || ucSelecionada.isEmpty)
                                  ? null 
                                  : () async {
                                      try {
                                        final novaEscala = EscalaModel(
                                          id: '',
                                          idCurso: cursoSelecionado,
                                          nomeUnidadeCurricular: ucSelecionada,
                                          idDocentes: docentesSelecionados.toList(),
                                          diaDaSemana: diaDaSemana,
                                          blocoTurno: turnoSelecionado,
                                          sala: 'A Definir',
                                        );

                                        await ref.read(escalaRepositoryProvider).addEscala(novaEscala);

                                        ref.invalidate(cursoSelecionadoProvider);
                                        ref.invalidate(ucSelecionadaProvider);
                                        ref.invalidate(docentesSelecionadosProvider);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Escala Guardada com Sucesso! ✅'), backgroundColor: Colors.green)
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Erro ao guardar: $e'), backgroundColor: Colors.red)
                                        );
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
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}