import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/escala_model.dart';

class EscalaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para gravar no Banco de Dados
  Future<void> criarEscala(EscalaModel escala) async {
    try {
      await _firestore.collection('escalas').add(escala.toMap());
    } catch (e) {
      throw Exception('Erro ao guardar escala: $e');
    }
  }
  
  // MOBILE: Função para o Professor escutar a sua própria agenda em Tempo Real
  Stream<List<EscalaModel>> streamEscalasDoDocente(String nomeProfessor) {
    return _firestore
        .collection('escalas')
        .where('idDocentes', arrayContains: nomeProfessor)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EscalaModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  
  // 3. ADMIN WEB: Função para o Coordenador ver toda a matriz de aulas
  Future<List<EscalaModel>> getAllEscalas() async {
    try {
      final snapshot = await _firestore.collection('escalas').get();
      return snapshot.docs.map((doc) {
        return EscalaModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar a matriz de escalas: $e');
    }
  }

  /// Grava uma nova escala com Validação de Choque de Horários
  Future<void> addEscala(EscalaModel escala) async {
    try {
      // 1. Busca aulas que acontecem no MESMO DIA e MESMO TURNO
      final snapshot = await _firestore
          .collection('escalas')
          .where('diaDaSemana', isEqualTo: escala.diaDaSemana)
          .where('blocoTurno', isEqualTo: escala.blocoTurno)
          .get();

      // 2. Verifica se algum professor selecionado já está dando aula nesse horário
      for (var doc in snapshot.docs) {
        final escalaExistente = EscalaModel.fromMap(doc.data(), doc.id);
        
        for (var professorNovo in escala.idDocentes) {
          if (escalaExistente.idDocentes.contains(professorNovo)) {
            // Se encontrar, dispara um erro claro bloqueando a gravação!
            throw Exception(
              'Choque de Horário: O professor $professorNovo já está alocado na ${escalaExistente.turma} (${escalaExistente.idCurso}) neste mesmo dia e turno.'
            );
          }
        }
      }

      // 3. Se passar na validação, salva normalmente
      await _firestore.collection('escalas').add(escala.toMap());
      
    } catch (e) {
      // Repassa a exceção para a tela exibir o erro
      rethrow; 
    }
  }
  /// Clona uma Escala Base para todo o semestre, criando instâncias diárias (para frequência e ajustes)
  Future<void> clonarEscalaParaSemestre({
    required EscalaModel escalaBase,
    required DateTime inicioSemestre,
    required DateTime fimSemestre,
    required List<DateTime> feriados,
  }) async {
    // 1. Inicia um lote de gravação (Batch)
    final batch = _firestore.batch();
    
    // Vamos salvar as ocorrências em uma subcoleção ou nova coleção para chamadas diárias
    final collectionRef = _firestore.collection('aulas_diarias'); 

    // Função auxiliar para converter o nome do dia da semana em número do DateTime
    int obterDiaDaSemanaInt(String dia) {
      switch (dia.toLowerCase()) {
        case 'segunda-feira': return DateTime.monday;
        case 'terça-feira': return DateTime.tuesday;
        case 'quarta-feira': return DateTime.wednesday;
        case 'quinta-feira': return DateTime.thursday;
        case 'sexta-feira': return DateTime.friday;
        case 'sábado': return DateTime.saturday;
        case 'domingo': return DateTime.sunday;
        default: return DateTime.monday;
      }
    }

    final diaAlvo = obterDiaDaSemanaInt(escalaBase.diaDaSemana);
    DateTime dataAtual = inicioSemestre;
    int totalAulasGeradas = 0;

    // 2. Varre o calendário do início ao fim do semestre
    while (dataAtual.isBefore(fimSemestre) || dataAtual.isAtSameMomentAs(fimSemestre)) {
      
      // Se o dia do calendário bater com o dia da semana da aula base...
      if (dataAtual.weekday == diaAlvo) {
        
        // Verifica se essa data cai em um feriado
        bool isFeriado = feriados.any((f) => 
          f.year == dataAtual.year && 
          f.month == dataAtual.month && 
          f.day == dataAtual.day
        );

        if (!isFeriado) {
          final docRef = collectionRef.doc(); // Gera um ID único para a aula do dia
          
          // Prepara os dados adicionando a DATA EXATA da ocorrência
          final dadosDaAula = escalaBase.toMap();
          dadosDaAula['dataExata'] = dataAtual.toIso8601String(); 
          dadosDaAula['status'] = 'Agendada'; // Pode ser: Agendada, Realizada, Cancelada

          batch.set(docRef, dadosDaAula);
          totalAulasGeradas++;
        }
      }
      
      // Avança um dia no calendário
      dataAtual = dataAtual.add(const Duration(days: 1));
    }

    // 3. Dispara a gravação de todas as aulas de uma única vez!
    if (totalAulasGeradas > 0) {
      try {
        await batch.commit();
      } catch (e) {
        throw Exception('Erro ao clonar o semestre: $e');
      }
    } else {
      throw Exception('Nenhuma aula gerada. Verifique as datas do semestre.');
    }
  }
  
}
