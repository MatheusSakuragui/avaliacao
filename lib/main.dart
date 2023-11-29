import 'package:flutter/material.dart';
import 'package:avaliacao/models/produto.dart';
import 'package:avaliacao/models/usuario.dart';
import 'package:avaliacao/database/sqlite.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  late DB _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    try {
      _database = DB.instance;
      print("Opening the database...");
      await _database.openDatabaseConnection();
      print("Database connection successful!");
    } catch (error) {
      print("Error opening the database: $error");
    }
  }

Future<bool> login(String email, String senha) async {
  try {
    List<Usuario> usuarios = await _database.getUserByEmailAndPassword(email, senha);
    if (usuarios.isNotEmpty) {
      return true;
    }
    return false;
  } catch (error) {
    print(error);
    return false;
  }
}

  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              'Login',
              style: TextStyle(fontSize: 25.0, color: Colors.black),
            ),
            
             SizedBox(
              width: 300, // ajuste conforme necessário
              child:
            TextField(
              controller: _usuario,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: "Insira seu Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
             ),
            const SizedBox(height: 50.0),
            SizedBox(
              width: 300, // ajuste conforme necessário
              child: TextField(
                obscureText: true,
                obscuringCharacter: "*",
                controller: _senha,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "Digite sua Senha",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            SizedBox(
              width: 170,
              child: ElevatedButton(
                onPressed: () async {
                  bool ret = await login(_usuario.text, _senha.text);
                  if(ret){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListagemProdutos(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login inválido, email ou senha incorretos!'),
                        backgroundColor: Color(Colors.red.value),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(220, 20),
                ),
                child: const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListagemProdutos extends StatefulWidget {
  const ListagemProdutos({
    Key? key,
  }) : super(key: key);

  @override
  ListagemProdutosState createState() => ListagemProdutosState();
}


class ListagemProdutosState extends State<ListagemProdutos> {
  late DB _database = DB.instance;
  List<int> selecionadosIndices = [];
  final List<Produto> _produtos = [];

  @override
  void initState() {
    super.initState();
    _loadDBinstance();
    loadProducts();
  }

  _loadDBinstance() async {
    try {
      _database = DB.instance;
    } catch (error) {
      print("Error on loading database instance: $error");
    }
  }

  loadProducts() async {
    try {
  //make a log of products
      List<Produto> listProduto = await _database.getProducts();
      print("Produtos: $listProduto");
      setState(() {
        _produtos.addAll(listProduto);
      });
    } catch (error) {
      print("Error on loading products: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
            ;
          },
        ),
        title: const Text("Login"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Produtos',
                style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                ),
                child: ListView.builder(
                  itemCount: _produtos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Produto produto = _produtos[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selecionadosIndices.contains(index)) {
                            selecionadosIndices.remove(index);
                          } else {
                            selecionadosIndices.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selecionadosIndices.contains(index)
                                ? Colors.green[100]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6.0),
                               Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '${produto.nome}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                  ),
                                  const SizedBox(height: 6.0),
                                      Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Categoria: ${produto.descricao}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),),
                                const SizedBox(height: 6.0),
                                    Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Valor: ${produto.preco.toStringAsFixed(2)} ',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                    ),
                                const SizedBox(height: 6.0),
                                    Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Quantidade: ${produto.quantidade}',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                    )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                List<Produto> produtosSelecionados = [];

                if (selecionadosIndices.isNotEmpty) {
                  for (int index in selecionadosIndices) {
                    produtosSelecionados.add(_produtos[index]);
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarrinhoCompra(
                      produtos: produtosSelecionados,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(180, 50),
              ),
              child: const Text('Ir para o Carrinho'),
            ),
            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}

class CarrinhoCompra extends StatefulWidget {
  final List<Produto> produtos;

  const CarrinhoCompra({Key? key, required this.produtos}) : super(key: key);

  @override
  CarrinhoCompraState createState() => CarrinhoCompraState();
}

class CarrinhoCompraState extends State<CarrinhoCompra> {
  final List<Produto> _produtos = [];
  List<int> quantidadesList = [];
  bool desconto = false;
  Color textColor = Colors.black;
  Color textColorWarning = Colors.grey;
  Color borderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    setState(() {
      _produtos.addAll(widget.produtos);
      quantidadesList = List<int>.filled(widget.produtos.length, 1);
    });
  }

  int calcularQuantidadeTotal() {
    int quantidadeTotal = 0;
    for (int quantidade in quantidadesList) {
      quantidadeTotal += quantidade;
    }
    if (quantidadeTotal >= 10) {
      setState(() {
        desconto = true;
      });
    }
    return quantidadeTotal;
  }

  List<double> calcularValorTotal() {
    int valorTotal = 0;
    for (int i = 0; i < _produtos.length; i++) {
      valorTotal += _produtos[i].preco * quantidadesList[i];
    }
    if (desconto) {
      double valorComDesconto =
          valorTotal.toDouble() - (valorTotal.toDouble() * 0.05);
      double valorDoDesconto = valorTotal.toDouble() * 0.05;
      return [valorComDesconto, valorDoDesconto];
    }
    return [valorTotal.toDouble(), 0.0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListagemProdutos()),
            );
            ;
          },
        ),
        title: const Text("Carrinho"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 50.0),
            Text('Quantidade de items = ${calcularQuantidadeTotal()}',
                style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold)),
            Text('Total: ${calcularValorTotal()[0]} Reais',
                style: TextStyle(fontSize: 19.0, color: Colors.black)),
            Text(desconto ? 'Desconto: 5%' : 'Desconto: 0%'),
            desconto ? Text("Desconto: ${calcularValorTotal()[1]}", style: TextStyle(fontSize: 15.0, color: Colors.green[100])) : Text(""),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                ),
                child: ListView.builder(
                  itemCount: _produtos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _produtos[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.nome}',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Valor: ${item.preco.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                          hintText: "Quantidade",
                          prefixIcon: Icon(Icons.shopping_cart_outlined),
                        ),
                                                onChanged: (value) {
                                        setState(() {
                                          quantidadesList[index] =
                                              int.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
               
                ElevatedButton(
                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        
                          content: Text('Pedido Enviado Com Sucesso'),
                      )
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                 
                  child: const Text('Finalizar pedido e sair',style: TextStyle(fontSize: 15.0, color: Colors.black)),
                ),
              ],
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                      builder: (context) => const ListagemProdutos(),
                      ),
                    );
                  },

                  child: const Text('Cancelar Pedido e Voltar', style: TextStyle(fontSize: 15.0, color: Colors.black)),
                ),
                  ]
                ),
          ],
        ),
      ),
    );
  }
}