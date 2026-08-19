// Ficheiro: lib/features/admin_web/manage_teachers/providers/docente_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/docente_repository.dart';
import '../../../../data/models/docente_model.dart';

// 1. Provider que fornece a instância do nosso Repositório.
// Dessa forma, se precisarmos "mockar" (simular) o banco para testes, mudamos apenas aqui.
final docenteRepositoryProvider = Provider<DocenteRepository>((ref) {
  return DocenteRepository();
});

// 2. FutureProvider que busca a lista de professores no Firebase.
// O Riverpod automaticamente gerencia os estados de Loading, Error e Data para nós!
final docentesListProvider = FutureProvider<List<DocenteModel>>((ref) async {
  // Lemos o repositório criado acima
  final repository = ref.read(docenteRepositoryProvider);
  // Retornamos a lista de docentes do Firebase
  return repository.getDocentes(); 
});