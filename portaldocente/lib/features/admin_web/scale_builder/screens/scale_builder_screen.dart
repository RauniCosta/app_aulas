// Ficheiro: lib/features/admin_web/scale_builder/screens/scale_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../manage_courses/providers/curso_providers.dart';
import '../../manage_teachers/providers/docente_providers.dart';
import '../../../../data/models/escala_model.dart';
import '../../../../data/models/curso_model.dart';
import '../../../../data/models/turma_model.dart';
import '../../../../data/models/docente_model.dart';
import '../../../../data/repositories/escala_repository.dart';

final escalaRepositoryProvider = Provider((ref) => EscalaRepository());
final cursoObjetoSelecionadoProvider = StateProvider.autoDispose<CursoModel?>(
  (ref) => null,
);
final turmaObjetoSelecionadaProvider = StateProvider.autoDispose<TurmaModel?>(
  (ref) => null,
);

// Classe auxiliar para guardar o estado de cada bloco da grade (UC + Professor)
class AlocacaoSlot {
  String? ucNome;
  DocenteModel? docente;
  AlocacaoSlot({this.ucNome, this.docente});
}

class ScaleBuilderScreen extends ConsumerStatefulWidget {
  const ScaleBuilderScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScaleBuilderScreen> createState() => _ScaleBuilderScreenState();
}

class _ScaleBuilderScreenState extends ConsumerState<ScaleBuilderScreen> {
  // Matriz que guarda o que acontece em cada dia/turno
  final Map<String, AlocacaoSlot> gradeDeAulas = {};
  bool _isSaving = false;

  final List<String> diasDaSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];

  // Função para criar siglas...
  String _gerarSigla(String texto) {
    if (texto.isEmpty) return '';
    final palavras = texto.split(' ').where((p) => p.length > 2).toList();
    if (palavras.isEmpty) return texto.substring(0, 1).toUpperCase();
    if (palavras.length == 1) return palavras[0].substring(0, 2).toUpperCase();
    return (palavras[0][0] + palavras[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cursoObjeto = ref.watch(cursoObjetoSelecionadoProvider);
    final turmaObjeto = ref.watch(turmaObjetoSelecionadaProvider);
    
    // --- CORREÇÃO: A lógica do 'if' entra AQUI DENTRO DO BUILD! ---
    List<String> turnosDaTurma = [];
    if (turmaObjeto != null) {
      // Filtra os blocos de horário baseados no período da turma
      if (turmaObjeto.periodo == 'Manhã') {
        turnosDaTurma = ['Manhã (08:00 - 12:30)'];
      } else if (turmaObjeto.periodo == 'Tarde') {
        turnosDaTurma = ['Tarde (13:30 - 17:30)'];
      } else if (turmaObjeto.periodo == 'Noite') {
        turnosDaTurma = ['Noite (18:30 - 22:30)'];
      } else if (turmaObjeto.periodo == 'Integral') {
        turnosDaTurma = ['Manhã (08:00 - 12:30)', 'Tarde (13:30 - 17:30)'];
      }
    } else {
      // Se nenhuma turma foi selecionada, mostra todos os turnos
      turnosDaTurma = ['Manhã', 'Tarde', 'Noite']; 
    }
    // -------------------------------------------------------------

    final cursosAsync = ref.watch(cursosListProvider);
    final docentesAsync = ref.watch(docentesListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Montagem de Escala por Turma'),
        backgroundColor: theme.primaryColor,
      ),
      body: Row(
        children: [
          // --- PAINEL LATERAL (DRAGGABLES COM DOCENTES REAIS) ---
          Container(
            width: 250,
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Professores',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Arraste para alocar',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Divider(height: 30),
                Expanded(
                  child: docentesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        const Center(child: Text('Erro ao carregar.')),
                    data: (docentes) {
                      if (docentes.isEmpty)
                        return const Text('Nenhum professor.');

                      return ListView.builder(
                        itemCount: docentes.length,
                        itemBuilder: (context, index) {
                          final docente = docentes[index];
                          final siglaProf = _gerarSigla(docente.nome);

                          return Draggable<DocenteModel>(
                            data: docente,
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  siglaProf,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildDocenteCard(docente, siglaProf),
                            ),
                            child: _buildDocenteCard(docente, siglaProf),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- ÁREA CENTRAL (GRADE DA TURMA) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SELEÇÃO DE CURSO E TURMA
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: cursosAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, s) => const Text('Erro'),
                              data: (cursos) => DropdownButtonFormField<CursoModel>(
                                decoration: const InputDecoration(
                                  labelText: 'Selecione o Curso',
                                  border: OutlineInputBorder(),
                                ),
                                value: cursoObjeto,
                                items: cursos
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.nome),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  ref
                                          .read(
                                            cursoObjetoSelecionadoProvider
                                                .notifier,
                                          )
                                          .state =
                                      val;
                                  ref
                                          .read(
                                            turmaObjetoSelecionadaProvider
                                                .notifier,
                                          )
                                          .state =
                                      null;
                                  gradeDeAulas
                                      .clear(); // Limpa a grade ao mudar de curso
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: (cursoObjeto == null)
                                ? const TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      labelText: 'Turma',
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                : Consumer(
                                    builder: (context, ref, child) {
                                      final turmasAsync = ref.watch(
                                        turmasPorCursoProvider(cursoObjeto.id),
                                      );
                                      return turmasAsync.when(
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (e, s) => const Text('Erro'),
                                        data: (turmas) =>
                                            DropdownButtonFormField<TurmaModel>(
                                              decoration: const InputDecoration(
                                                labelText: 'Selecione a Turma',
                                                border: OutlineInputBorder(),
                                              ),
                                              value: turmaObjeto,
                                              items: turmas
                                                  .map(
                                                    (t) => DropdownMenuItem(
                                                      value: t,
                                                      child: Text(t.nome),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (val) =>
                                                  ref
                                                          .read(
                                                            turmaObjetoSelecionadaProvider
                                                                .notifier,
                                                          )
                                                          .state =
                                                      val,
                                            ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. A GRADE DA TURMA (HORÁRIOS X DIAS)
                  if (turmaObjeto == null)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Selecione uma turma para montar o horário.',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            // Coluna Fixa: Turnos
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  ...turnosDaTurma
                                      .map(
                                        (t) => Expanded(
                                          child: Center(
                                            child: Text(
                                              t,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                            // Colunas dos Dias da Semana
                            Expanded(
                              child: Row(
                                children: diasDaSemana.map((dia) {
                                  return Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 40,
                                            alignment: Alignment.center,
                                            color: Colors.blueGrey.shade50,
                                            child: Text(
                                              dia,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          ...turnosDaTurma.map((turno) {
                                            final chave = '$dia|$turno';
                                            gradeDeAulas.putIfAbsent(
                                              chave,
                                              () => AlocacaoSlot(),
                                            );
                                            final slot = gradeDeAulas[chave]!;

                                            return Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // Dropdown compacto da UC
                                                    Consumer(
                                                      builder: (context, ref, _) {
                                                        final ucsAsync = ref
                                                            .watch(
                                                              ucsPorCursoProvider(
                                                                cursoObjeto!.id,
                                                              ),
                                                            );
                                                        return ucsAsync.maybeWhen(
                                                          data: (ucs) => DropdownButton<String>(
                                                            isExpanded: true,
                                                            underline:
                                                                const SizedBox(),
                                                            hint: const Text(
                                                              'UC',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                            value: slot.ucNome,
                                                            items: ucs
                                                                .map(
                                                                  (
                                                                    uc,
                                                                  ) => DropdownMenuItem(
                                                                    value:
                                                                        uc.nome,
                                                                    child: Text(
                                                                      _gerarSigla(
                                                                        uc.nome,
                                                                      ),
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                            onChanged: (val) =>
                                                                setState(
                                                                  () =>
                                                                      slot.ucNome =
                                                                          val,
                                                                ),
                                                          ),
                                                          orElse: () =>
                                                              const SizedBox.shrink(),
                                                        );
                                                      },
                                                    ),

                                                    // Área de Drag and Drop para o Professor
                                                    Expanded(
                                                      child: DragTarget<DocenteModel>(
                                                        onWillAccept: (_) =>
                                                            slot.ucNome !=
                                                            null, // Só aceita professor se a UC estiver definida
                                                        onAccept: (docente) =>
                                                            setState(
                                                              () =>
                                                                  slot.docente =
                                                                      docente,
                                                            ),
                                                        builder:
                                                            (
                                                              context,
                                                              candidateData,
                                                              rejectedData,
                                                            ) {
                                                              final isHovering =
                                                                  candidateData
                                                                      .isNotEmpty;
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      isHovering
                                                                      ? theme
                                                                            .colorScheme.secondary
                                                                            .withOpacity(
                                                                              0.3,
                                                                            )
                                                                      : (slot.docente !=
                                                                                null
                                                                            ? theme.primaryColor.withOpacity(
                                                                                0.1,
                                                                              )
                                                                            : Colors.grey.shade50),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                                child:
                                                                    slot.docente !=
                                                                        null
                                                                    ? Stack(
                                                                        children: [
                                                                          Center(
                                                                            child: Text(
                                                                              _gerarSigla(
                                                                                slot.docente!.nome,
                                                                              ),
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: theme.primaryColor,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            top:
                                                                                -5,
                                                                            right:
                                                                                -5,
                                                                            child: IconButton(
                                                                              icon: const Icon(
                                                                                Icons.close,
                                                                                size: 12,
                                                                                color: Colors.red,
                                                                              ),
                                                                              onPressed: () => setState(
                                                                                () => slot.docente = null,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Center(
                                                                        child: Icon(
                                                                          Icons
                                                                              .person_add_alt,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400,
                                                                          size:
                                                                              18,
                                                                        ),
                                                                      ),
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.black87,
                            ),
                            onPressed:
                                (cursoObjeto == null || turmaObjeto == null)
                                ? null
                                : () => _salvarGradeNoBanco(
                                    cursoObjeto,
                                    turmaObjeto,
                                  ),
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Salvar Escala da Turma',
                              style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildDocenteCard(DocenteModel docente, String sigla) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Text(
              sigla,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              docente.nome,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 14),
        ],
      ),
    );
  }

  Future<void> _salvarGradeNoBanco(CursoModel curso, TurmaModel turma) async {
    setState(() => _isSaving = true);
    int salvas = 0;

    try {
      final repo = ref.read(escalaRepositoryProvider);

      for (var entry in gradeDeAulas.entries) {
        final chave = entry.key;
        final slot = entry.value;

        // Só salva se o coordenador preencheu a UC e jogou um professor lá dentro
        if (slot.ucNome == null || slot.docente == null) continue;

        final partes = chave.split('|');
        final dia = partes[0];
        final turno = partes[1];

        final novaEscala = EscalaModel(
          id: '',
          idCurso: curso.id, // O ideal é gravar o ID para futuras relações
          turma: turma.nome,
          nomeUnidadeCurricular: slot.ucNome!,
          idDocentes: [slot.docente!.nome],
          diaDaSemana: dia,
          blocoTurno: turno,
          sala: 'A Definir',
        );

        await repo.addEscala(novaEscala);
        salvas++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$salvas aulas da ${turma.nome} salvas e validadas! ✅',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
