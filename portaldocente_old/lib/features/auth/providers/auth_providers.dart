// Ficheiro: lib/features/auth/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Instância do Firebase Auth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// 2. Stream que escuta se há alguém logado ou não (Tempo real)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// 3. FutureProvider que vai ao Firestore descobrir qual é o "role" do utilizador logado
final userRoleProvider = FutureProvider.family<String, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  
  if (doc.exists && doc.data() != null) {
    return doc.data()!['role'] ?? 'docente'; // Por defeito, assumimos docente
  }
  return 'docente'; 
});