import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';

class DatabaseHelper {
  // Padrão Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDb() async {
    String caminhoBanco = join(await getDatabasesPath(), 'tarefas.db');
    return await openDatabase(
      caminhoBanco,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Cria a tabela
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        descricao TEXT,
        concluida INTEGER
      )
    ''');
  }

  // --- MÉTODOS CRUD ---

  // CREATE (Inserir)
  Future<int> inserirTarefa(Tarefa tarefa) async {
    Database db = await database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  // READ (Ler todas)
  Future<List<Tarefa>> obterTarefas() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('tarefas');
    return List.generate(maps.length, (i) {
      return Tarefa.fromMap(maps[i]);
    });
  }

  // UPDATE (Atualizar)
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    Database db = await database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  // DELETE (Excluir)
  Future<int> deletarTarefa(int id) async {
    Database db = await database;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}