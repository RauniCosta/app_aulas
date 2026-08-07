// Importa o pacote Flutter Material, que contém widgets e temas de design Material.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/gerador_aleatorio.dart';

// A classe HomePage herda de StatefulWidget.
// Isso indica que este Widget possui um "estado" interno que pode mudar durante a execução (ex: contador, formulários).
// Diferente de um StatelessWidget (que é estático), o StatefulWidget pode ser reconstruído para refletir mudanças de dados.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // O método createState é obrigatório e cria a instância da classe (_HomePageState)
  // que vai conter as variáveis e a lógica que controlam este Widget.
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var numeroGerado = 0;
  var contador = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Página Inicial',
          //style: GoogleFonts.pacifico(),
        ),
      ),
      body: Container( // Usa um Container como corpo da página
        // Adiciona uma margem ao redor do Container
        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
        color: Colors.cyan[200],
        child: Column(
          // Organiza os widgets em uma coluna vertical
          crossAxisAlignment: CrossAxisAlignment.start,
          // Alinha os widgets ao centro verticalmente
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              numeroGerado.toString(),
              style: TextStyle(
                fontSize: 24,
                color: const Color.fromARGB(255, 11, 26, 240),
              ),
            ),
            Text(
              'Quantidade de Números Gerados: $contador',
              textAlign: TextAlign.center,
              style: GoogleFonts.acme(
                fontSize: 20,
                color: const Color.fromARGB(255, 87, 3, 184),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //expanded para dividir o espaço entre os containers
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.amber,
                    child: Text("10",
                    style: 
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        ),
                      ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child:Text("20",
                  style: 
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        ),
                      ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 50,
                  child: Container(
                    color: Colors.blue,
                    child:Text("30",
                  style: 
                     GoogleFonts.arOneSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        ),
                      ),
                  ),
                ),
                Container(
                  width: 150,
                  height: 150,
                  color: Colors.green,
                  child:Text("40",
                style: 
                    TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      ),
                    ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            numeroGerado = GeradorAleatorio.gerarNumeroAleatorio(100);
            contador++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
