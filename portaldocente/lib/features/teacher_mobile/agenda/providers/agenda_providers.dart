// Ficheiro: lib/features/teacher_mobile/agenda/providers/agenda_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/escala_model.dart';
import '../../../../data/repositories/escala_repository.dart';

final escalaRepoProvider = Provider((ref) => EscalaRepository());

// StreamProvider: Escuta o Firebase em TEMPO REAL!
final agendaDoProfessorProvider = StreamProvider.autoDispose<List<EscalaModel>>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield [];
    return;
  }

  // 1. Busca o nome do professor logado no documento do usuário
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  
  // O .trim() remove espaços vazios acidentais que possam quebrar a busca no Firebase
  final nomeProfessor = userDoc.data()?['nome']?.toString().trim() ?? '';

  if (nomeProfessor.isEmpty) {
    yield [];
    return;
  }

  // 2. Retorna o Stream em tempo real da coleção 'escalas'
  final repo = ref.read(escalaRepoProvider);
  
  // Usamos o await for para garantir que a stream seja repassada corretamente
  final stream = repo.streamEscalasDoDocente(nomeProfessor);
  await for (final escalas in stream) {
    yield escalas;
  }
});