// Ficheiro: lib/features/admin_web/manage_courses/providers/curso_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// 3. FutureProvider que busca as UCs REAIS de um curso específico no Firebase
final ucsPorCursoProvider = FutureProvider.family<List<UnidadeCurricularModel>, String>((ref, cursoId) async {
  final repository = ref.read(cursoRepositoryProvider);
  return repository.getUCsPorCurso(cursoId);
});