// Ficheiro: lib/features/teacher_mobile/perfil/screens/perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../agenda/providers/agenda_providers.dart';

// Provider para buscar os dados cadastrais do docente logado
final dadosDocenteLogadoProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  // 1. Procura na coleção 'users' pelo UID do Firebase Auth
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!userDoc.exists) return null;

  final userData = userDoc.data();
  final docenteId = userData?['docenteId'];

  // 2. Se tiver o ID do docente vinculado, busca os dados da coleção 'docentes'
  if (docenteId != null && docenteId.toString().isNotEmpty) {
    final docenteDoc = await FirebaseFirestore.instance.collection('docentes').doc(docenteId).get();
    if (docenteDoc.exists) {
      return docenteDoc.data();
    }
  }

  return userData;
});

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final dadosDocenteAsync = ref.watch(dadosDocenteLogadoProvider);
    final agendaAsync = ref.watch(agendaDoProfessorProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BB2),
        elevation: 0,
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- CARTÃO DE IDENTIFICAÇÃO DO DOCENTE ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xFF1E5BB2).withOpacity(0.1),
                      child: const Icon(Icons.person, size: 50, color: Color(0xFF1E5BB2)),
                    ),
                    const SizedBox(height: 15),
                    
                    dadosDocenteAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text(user?.email ?? 'Professor'),
                      data: (dados) {
                        final nome = dados?['nome'] ?? 'Professor';
                        final email = dados?['email'] ?? user?.email ?? '';
                        return Column(
                          children: [
                            Text(
                              nome,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E5BB2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Corpo Docente',
                        style: TextStyle(color: Color(0xFF1E5BB2), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- CARTÃO 1: DIAS DE ATUAÇÃO CADASTRADOS ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Color(0xFF1E5BB2)),
                        SizedBox(width: 10),
                        Text(
                          'Dias de Atuação Cadastrados',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 25),
                    dadosDocenteAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => const Text('Não foi possível carregar os dias.'),
                      data: (dados) {
                        final List<dynamic> dias = dados?['diasEscala'] ?? [];
                        if (dias.isEmpty) {
                          return Text(
                            'Nenhum dia de atuação definido no seu cadastro.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: dias.map((dia) {
                            return Chip(
                              avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              label: Text(dia.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              backgroundColor: Colors.green.withOpacity(0.1),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- CARTÃO 2: RESUMO DA ESCALA ATUAL (AULAS ALOCADAS) ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_ind, color: Color(0xFF1E5BB2)),
                        SizedBox(width: 10),
                        Text(
                          'Resumo da Escala Atual',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 25),
                    agendaAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => const Text('Erro ao carregar escala.'),
                      data: (escalas) {
                        if (escalas.isEmpty) {
                          return Text(
                            'Você não possui turmas/escalas alocadas no momento.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          );
                        }

                        final totalAulas = escalas.length;
                        final cursosSet = escalas.map((e) => e.idCurso).toSet();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Aulas/Blocos', totalAulas.toString(), Icons.class_),
                                Container(width: 1, height: 40, color: Colors.grey[300]),
                                _buildStatItem('Cursos Ativos', cursosSet.length.toString(), Icons.school),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Disciplinas sob sua responsabilidade:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            ...escalas.map((escala) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_right, color: Color(0xFF1E5BB2)),
                                    Expanded(
                                      child: Text(
                                        '${escala.nomeUnidadeCurricular} (${escala.idCurso}) - ${escala.diaDaSemana}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- BOTÃO TERMINAR SESSÃO (LOGOUT) ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Terminar Sessão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1E5BB2)),
            const SizedBox(width: 5),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E5BB2))),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}