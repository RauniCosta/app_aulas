// Ficheiro: lib/data/repositories/curso_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portaldocente/data/models/turma_model.dart';
import '../models/curso_model.dart';
import '../models/unidade_curricular_model.dart';

class CursoRepository {
  final FirebaseFirestore _firestore;

  CursoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==========================================
  // MÉTODOS PARA CURSOS
  // ==========================================

  /// Busca todos os cursos cadastrados
  Future<List<CursoModel>> getCursos() async {
    try {
      final snapshot = await _firestore.collection('cursos').get();
      return snapshot.docs.map((doc) {
        return CursoModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar cursos: $e');
    }
  }

  /// Adiciona um novo curso
  Future<void> addCurso(CursoModel curso) async {
    try {
      await _firestore.collection('cursos').add(curso.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar curso: $e');
    }
  }

  /// Exclui um curso
  Future<void> deleteCurso(String id) async {
    try {
      await _firestore.collection('cursos').doc(id).delete();
      // Opcional: Aqui poderíamos adicionar uma lógica para deletar as UCs associadas a este curso
    } catch (e) {
      throw Exception('Erro ao excluir curso: $e');
    }
  }

  // ==========================================
  // MÉTODOS PARA UNIDADES CURRICULARES (UCs)
  // ==========================================

  /// Busca as UCs de um curso específico
  Future<List<UnidadeCurricularModel>> getUCsPorCurso(String cursoId) async {
    try {
      final snapshot = await _firestore
          .collection('ucs')
          .where('cursoId', isEqualTo: cursoId)
          .get();

      return snapshot.docs.map((doc) {
        return UnidadeCurricularModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar UCs do curso: $e');
    }
  }

  /// Adiciona uma nova UC vinculada a um curso
  Future<void> addUC(UnidadeCurricularModel uc) async {
    try {
      await _firestore.collection('ucs').add(uc.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar UC: $e');
    }
  }
  
  /// Exclui uma UC
  Future<void> deleteUC(String id) async {
    try {
      await _firestore.collection('ucs').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir UC: $e');
    }
  }

  /// Atualiza um curso existente
  Future<void> updateCurso(CursoModel curso) async {
    try {
      await _firestore.collection('cursos').doc(curso.id).update(curso.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar curso: $e');
    }
  }

  /// Atualiza uma UC existente
  Future<void> updateUC(UnidadeCurricularModel uc) async {
    try {
      await _firestore.collection('ucs').doc(uc.id).update(uc.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar UC: $e');
    }
  }

  // --- TURMAS ---

  /// Adiciona uma nova turma vinculada a um curso
  Future<void> addTurma(TurmaModel turma) async {
    try {
      await _firestore.collection('turmas').add(turma.toMap());
    } catch (e) {
      throw Exception('Erro ao cadastrar turma: $e');
    }
  }

  /// Busca todas as turmas cadastradas para um determinado curso
  Future<List<TurmaModel>> getTurmasPorCurso(String cursoId) async {
    try {
      final snapshot = await _firestore
          .collection('turmas')
          .where('cursoId', isEqualTo: cursoId)
          .get();

      return snapshot.docs.map((doc) => TurmaModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar turmas: $e');
    }
  }
  
}