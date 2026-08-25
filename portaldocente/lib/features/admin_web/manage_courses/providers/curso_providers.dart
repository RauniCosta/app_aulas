// Ficheiro: lib/features/admin_web/manage_courses/providers/curso_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edusync/data/models/turma_model.dart';
import '../../../../data/repositories/curso_repository.dart';
import '../../../../data/models/curso_model.dart';
import '../../../../data/models/unidade_curricular_model.dart';

// 1. Provider do Repositório (Instância única)
final cursoRepositoryProvider = Provider<CursoRepository>((ref) {
  return CursoRepository();
});

// 2. FutureProvider que busca a lista de cursos REAIS no Firebase
final cursosListProvider = FutureProvider<List<CursoModel>>((ref) async {
  final repository = ref.read(cursoRepositoryProvider);
  return repository.getCursos();
});

// 1. Provider de UCs ORDENADAS ALFABETICAMENTE
final ucsPorCursoProvider = FutureProvider.family.autoDispose<List<UnidadeCurricularModel>, String>((ref, cursoId) async {
  final repo = ref.read(cursoRepositoryProvider);
  final ucs = await repo.getUCsPorCurso(cursoId);
  
  // ORDENAÇÃO ALFABÉTICA (A -> Z)
  ucs.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  return ucs;
});

// 2. NOVO: Provider de Turmas por Curso
final turmasPorCursoProvider = FutureProvider.family.autoDispose<List<TurmaModel>, String>((ref, cursoId) async {
  final repo = ref.read(cursoRepositoryProvider);
  return await repo.getTurmasPorCurso(cursoId);
});