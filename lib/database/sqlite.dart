import "package:avaliacao/models/produto.dart";
import "package:avaliacao/models/usuario.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

class DB {
  late Database _database;
  static late final DB _instance = DB._();

  DB._();

  static DB get instance => _instance;

  late List<String> inserts = [
    "INSERT IGNORE INTO usuarios(id, nome, email, senha) VALUES(1,'Matheus', 'mat@gmail.com', 'senha')",
    "INSERT IGNORE INTO usuarios(id, nome, email, senha) VALUES(2,'Mariana', 'mari@gmail.com','senha')",
    "INSERT IGNORE INTO usuarios(id, nome, email, senha) VALUES(3,'Nathan', 'nat@gmail.com','senha')",
    "INSERT IGNORE INTO usuarios(id, nome, email, senha) VALUES(4,'Tais', 'tata@gmail.com','senha')",
  ];

  Future<void> openDatabaseConnection() async {
    final String path = join(await getDatabasesPath(), 'database.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('DROP TABLE IF EXISTS usuarios');
        await db.execute('DROP TABLE IF EXISTS produtos');
        await db.execute('DROP TABLE IF EXISTS compras');
        await db.execute(
          '''CREATE TABLE usuarios(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              nome TEXT, 
              email TEXT, 
              senha TEXT
            )
          ''',
        );

        await db.execute('''
          CREATE TABLE produtos(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            nome TEXT,
            descricao Text,
            preco INTEGER,
            quantidade INTEGER
          )
      ''');

        await db.execute('''
          CREATE TABLE compras(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            id_produto INTEGER
          )
      ''');
      },
    );
    List<Usuario> users = await getAllUsuarios();
    if (users.isEmpty) {
      print("Executando inserts...");
      for (int i = 0; i < inserts.length; i++) {
        String query = inserts[i];
        await _database.execute(query);
      }
    } else {
      print("Inserts ja executados");
    }

   await getProductsFromApi();
  }

  Future<List<Usuario>> getAllUsuarios() async {
    final List<Map<String, dynamic>> maps = await _database.query('usuarios');
    return List.generate(maps.length, (i) {
      return Usuario(
          id: maps[i]['id'],
          nome: maps[i]['nome'],
          email: maps[i]["email"],
          senha: maps[i]['senha']);
    });
  }

  Future<List<Usuario>> getUserByEmailAndPassword(String email, String senha) async {
    String query = "SELECT * FROM usuarios WHERE email = ? AND senha = ?";
    final List<Map<String, dynamic>> maps = await _database.rawQuery(query, ['$email', '$senha']);
    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return Usuario(
            id: maps[i]['id'],
            nome: maps[i]['nome'],
            email: maps[i]["email"],
            senha: maps[i]['senha']);
      });
    }else{
      return [];
    }
  }

  Future<void> getProductsFromApi() async {
    final response = await http.get(Uri.parse(
        'https://loja-mcyhir2om-rodrigoribeiro027.vercel.app/produtos/buscar'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      for (int i = 0; i < jsonResponse.length; i++) {
        print(jsonResponse[i]['nome']);
        List<Produto> produtos = await getProductByName(jsonResponse[i]['nome']);
        if (!produtos.isEmpty) {
          String query =
              "INSERT INTO produtos(nome,descricao, preco, quantidade) VALUES('${jsonResponse[i]['nome']}','${jsonResponse[i]['descricao']}', ${jsonResponse[i]['preco']}, ${jsonResponse[i]['quantidade']})";
          await _database.execute(query);
          print("Produto ${jsonResponse[i]['nome']} inserido");
        }
      }
      print('Request successful, products updated.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<List<Produto>> getProductByName(String name) async {
    String query = "SELECT * FROM produtos WHERE nome LIKE ?";
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery(query, ['%$name%']);

    if (maps.isEmpty) {
      return [];
    } else {
      return List.generate(maps.length, (i) {
        return Produto(
          id: maps[i]['id'],
          nome: maps[i]['nome'],
          preco: maps[i]['preco'],
          descricao: maps[i]['descricao'],
          quantidade: maps[i]['quantidade'],
        );
      });
    }
  }

  Future<List<Produto>> getProducts() async {
    String query = "SELECT * FROM produtos";
    final List<Map<String, dynamic>> maps = await _database.rawQuery(query, []);
    print(maps.length);
    return List.generate(maps.length, (i) {
      return Produto(
          id: maps[i]['id'],
          nome: maps[i]['nome'],
          preco: maps[i]['preco'],
          descricao: maps[i]['descricao'],
          quantidade: maps[i]['quantidade']);
    });
  }
}