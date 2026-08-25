// Ficheiro: lib/features/teacher_mobile/scale_overview/screens/cursos_docentes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agenda/providers/agenda_providers.dart';
import '../../../../data/models/escala_model.dart';

// NOVO: Imports para traduzir os Cursos
import '../../../../data/models/curso_model.dart';
import '../../../admin_web/manage_courses/providers/curso_providers.dart';

class CursosDocentesScreen extends ConsumerWidget {
  const CursosDocentesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Buscamos todas as escalas atribuídas a este professor
    final agendaAsync = ref.watch(agendaDoProfessorProvider);
    
    // Lê a lista de cursos silenciosamente e de forma segura
    final cursosAsync = ref.watch(cursosListProvider);
    final listaCursos = cursosAsync.maybeWhen(
      data: (cursos) => cursos,
      orElse: () => <CursoModel>[],
    );

    // Função tradutora
    String obterNomeCurso(String idCurso) {
      for (final curso in listaCursos) {
        if (curso.id == idCurso) return curso.nome;
      }
      return idCurso; 
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Minhas Turmas e UCs', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF2E8B57),
        elevation: 0,
        centerTitle: true,
      ),
      body: agendaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar turmas: $err')),
        data: (escalas) {
          if (escalas.isEmpty) {
            return _buildEmptyState();
          }

          // Agrupa as escalas pela chave "Curso + Turma".
          final Map<String, List<EscalaModel>> turmasAgrupadas = {};
          
          for (var escala in escalas) {
            final chave = '${escala.idCurso} | ${escala.turma}';
            if (!turmasAgrupadas.containsKey(chave)) {
              turmasAgrupadas[chave] = [];
            }
            turmasAgrupadas[chave]!.add(escala);
          }

          final chavesUnicas = turmasAgrupadas.keys.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Grid com 2 colunas
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16,  
              childAspectRatio: 0.78, 
            ),
            itemCount: chavesUnicas.length,
            itemBuilder: (context, index) {
              final chave = chavesUnicas[index];
              final escalasDaTurma = turmasAgrupadas[chave]!;
              
              // AQUI ESTÁ A CORREÇÃO: Traduz o ID para o nome real
              final cursoNome = obterNomeCurso(escalasDaTurma.first.idCurso);
              final turmaNome = escalasDaTurma.first.turma;
              
              final ucsUnicas = escalasDaTurma.map((e) => e.nomeUnidadeCurricular).toSet().toList();

              return _buildCourseCard(context, cursoNome, turmaNome, ucsUnicas);
            },
          );
        },
      ),
    );
  }

  // --- WIDGET DO CARD DA TURMA ---
  Widget _buildCourseCard(BuildContext context, String curso, String turma, List<String> ucs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF2E8B57), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    turma, 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Corpo do Card
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso, // Agora ele receberá o Nome do Curso traduzido!
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    '${ucs.length} UC(s) atribuída(s)',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),

                ...ucs.take(2).map((uc) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $uc',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),

                if (ucs.length > 2)
                  Text(
                    '+ ${ucs.length - 2} outras...',
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET QUANDO NÃO HÁ TURMAS ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma turma atribuída',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              'Você ainda não foi alocado em nenhuma escala ou turma pela coordenação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}