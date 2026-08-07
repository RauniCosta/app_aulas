// lib/models/usuario_model.dart

class UsuarioModel {
  String uid;
  String nome;
  String email;
  double multaAcumulada;

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    this.multaAcumulada = 0.0, // Começa com zero de multa por padrão
  });

  // Função que pega os dados vindos do Firebase (Formato Mapa/JSON) 
  // e transforma no nosso objeto UsuarioModel
  factory UsuarioModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UsuarioModel(
      uid: documentId,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      multaAcumulada: (map['multa_acumulada'] ?? 0.0).toDouble(),
    );
  }

  // Função inversa: Pega o nosso objeto e transforma em Mapa 
  // para podermos salvar/enviar para o Firebase
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'multa_acumulada': multaAcumulada,
      // Não enviamos a senha para o Firestore! Ela fica restrita ao FirebaseAuth.
    };
  }
}