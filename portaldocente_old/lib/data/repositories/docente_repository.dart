// Ficheiro: lib/data/repositories/docente_repository.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/docente_model.dart';

class DocenteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocenteRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Nome da coleção no Firestore
  CollectionReference get _docentesRef => _firestore.collection('docentes');

  /// Procura todos os professores cadastrados
  Future<List<DocenteModel>> getDocentes() async {
    try {
      final snapshot = await _docentesRef.get();
      return snapshot.docs.map((doc) {
        return DocenteModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar docentes: $e');
    }
  }

  /// Procura um professor específico pelo seu ID
  Future<DocenteModel?> getDocenteById(String id) async {
    try {
      final doc = await _docentesRef.doc(id).get();
      if (doc.exists) {
        return DocenteModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao procurar docente: $e');
    }
  }

 /// Adiciona um novo docente sem deslogar o Administrador!
  Future<void> addDocente(DocenteModel docente, String senhaProvisoria) async {
    try {
      final docRef = await _docentesRef.add(docente.toMap());
      final docenteId = docRef.id;

      // TRUQUE: Cria uma instância temporária do Firebase apenas para registrar o professor
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'TemporaryRegisterApp',
        options: Firebase.app().options,
      );

      // Usa a instância temporária para criar a conta (assim não afeta o login atual do Admin)
      final userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(
        email: docente.email,
        password: senhaProvisoria,
      );

      final uidAuth = userCredential.user!.uid;

      await _firestore.collection('users').doc(uidAuth).set({
        'email': docente.email,
        'nome': docente.nome,
        'role': 'docente',
        'docenteId': docenteId,
      });

      // Destrói a app temporária. O Admin continua logado na app principal!
      await tempApp.delete();

    } catch (e) {
      throw Exception('Erro ao adicionar docente e criar utilizador: $e');
    }
  }

  /// NOVO: Função para excluir um docente da base de dados
  Future<void> deleteDocente(String id) async {
    try {
      await _docentesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir docente: $e');
    }
  }
  
  /// Atualiza os dados de um docente existente
  Future<void> updateDocente(DocenteModel docente) async {
    try {
      await _docentesRef.doc(docente.id).update(docente.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar docente: $e');
    }
  }
}