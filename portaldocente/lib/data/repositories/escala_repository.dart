// Ficheiro: lib/data/repositories/escala_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/escala_model.dart';

class EscalaRepository {
  final FirebaseFirestore _firestore;

  EscalaRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _escalasRef => _firestore.collection('escalas');

  /// Procura a agenda de um professor específico (Filtrando por ID/Nome do docente no Array)
  Future<List<EscalaModel>> getEscalasDoDocente(String idDocente) async {
    try {
      final snapshot = await _escalasRef
          .where('idDocentes', arrayContains: idDocente)
          // REMOVIDO: .orderBy('dataHoraInicio') pois agora usamos Blocos/Turnos
          .get();

      return snapshot.docs.map((doc) {
        return EscalaModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar a agenda do docente: $e');
    }
  }

  /// Escuta as escalas em tempo real (Stream) - Excelente para atualizações instantâneas no App Mobile
  Stream<List<EscalaModel>> streamEscalasDoDocente(String idDocente) {
    return _escalasRef
        .where('idDocentes', arrayContains: idDocente)
        // REMOVIDO: .orderBy('dataHoraInicio')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EscalaModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Grava apenas uma NOVA escala (Usado pelo Painel Web no ScaleBuilderScreen)
  Future<void> addEscala(EscalaModel escala) async {
    try {
      await _escalasRef.add(escala.toMap());
    } catch (e) {
      throw Exception('Erro ao guardar a escala: $e');
    }
  }

  /// Grava ou Atualiza uma escala existente
  Future<void> salvarEscala(EscalaModel escala) async {
    try {
      if (escala.id.isEmpty) {
        await addEscala(escala);
      } else {
        await _escalasRef.doc(escala.id).update(escala.toMap());
      }
    } catch (e) {
      throw Exception('Erro ao salvar/atualizar a escala: $e');
    }
  }
}