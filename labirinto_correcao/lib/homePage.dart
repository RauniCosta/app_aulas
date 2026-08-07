import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TelaDoJogo extends StatefulWidget {
  @override
  _TelaDoJogoState createState() => _TelaDoJogoState();
}

class _TelaDoJogoState extends State<TelaDoJogo> {
  late List<List<int>> mapaDoLabirinto;

  int posicaopersonagemX = 1;
  int posicaopersonagemY = 1;

  int nivelAtual = 1;
  int tamanhoAtualDaMatriz = 7;

  bool jogoIniciado = false;

  int passosDados = 0;
  int tempoRestante = 40;

  int vidas = 5;

  Timer? cronometro;

  final int raioDeVisao = 1;

  // 🔽 ADICIONE ESTAS LINHAS ABAIXO:
  bool _podeMoverGesto =
      true; // Impede que o gatinho ande 50 casas com um único deslize

  void _tratarDeslize(DragUpdateDetails detalhes) {
    if (!jogoIniciado || !_podeMoverGesto) return;

    // Sensibilidade: só move se o dedo arrastar uma distância razoável
    if (detalhes.delta.distance > 4) {
      _podeMoverGesto = false;
      int movimentoX = 0;
      int movimentoY = 0;

      // Descobre se o movimento foi mais Horizontal ou Vertical
      if (detalhes.delta.dx.abs() > detalhes.delta.dy.abs()) {
        movimentoX = detalhes.delta.dx > 0 ? 1 : -1; // Direita ou Esquerda
      } else {
        movimentoY = detalhes.delta.dy > 0 ? 1 : -1; // Baixo ou Cima
      }

      moverComBotao(movimentoX, movimentoY);

      // Trava temporária de 250 milissegundos para dar precisão ao movimento
      Timer(Duration(milliseconds: 250), () {
        _podeMoverGesto = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
  }

  List<List<int>> gerarLabirinto(int tamanho) {
    List<List<int>> novoMapa = List.generate(
      tamanho,
      (_) => List.filled(tamanho, 1),
    );

    Random aleatorio = Random();

    void cavarCaminho(int x, int y) {
      novoMapa[y][x] = 0;

      List<List<int>> direcoes = [
        [0, -2],
        [2, 0],
        [0, 2],
        [-2, 0],
      ];

      direcoes.shuffle(aleatorio);

      for (var direcao in direcoes) {
        int proximoX = x + direcao[0];
        int proximoY = y + direcao[1];

        if (proximoY > 0 &&
            proximoY < tamanho - 1 &&
            proximoX > 0 &&
            proximoX < tamanho - 1 &&
            novoMapa[proximoY][proximoX] == 1) {
          novoMapa[y + (direcao[1] ~/ 2)][x + (direcao[0] ~/ 2)] = 0;

          cavarCaminho(proximoX, proximoY);
        }
      }
    }

    cavarCaminho(1, 1);

    novoMapa[1][1] = 2;

    novoMapa[tamanho - 2][tamanho - 2] = 3;

    novoMapa[tamanho - 2][tamanho - 3] = 0;
    novoMapa[tamanho - 3][tamanho - 2] = 0;

    return novoMapa;
  }

  void iniciarJogo() {
    setState(() {
      jogoIniciado = true;
    });

    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        tempoRestante--;

        if (tempoRestante <= 0) {
          perdeuPorTempo();
        }
      });
    });
  }

  void reiniciarJogo() {
    cronometro?.cancel();

    setState(() {
      posicaopersonagemX = 1;
      posicaopersonagemY = 1;

      nivelAtual = 1;
      tamanhoAtualDaMatriz = 7;

      vidas = 5;

      passosDados = 0;

      tempoRestante = 40;

      jogoIniciado = false;

      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
    });
  }

  void perdeuPorTempo() {
    cronometro?.cancel();

    jogoIniciado = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("⏰ Tempo acabou!", style: TextStyle(color: Colors.white)),
        content: Text(
          "O gatinho não encontrou o novelo 😿",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              reiniciarJogo();
            },
            child: Text("Tentar novamente"),
          ),
        ],
      ),
    );
  }

  void perdeuPorVidas() {
    cronometro?.cancel();

    jogoIniciado = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("💔 Sem vidas!", style: TextStyle(color: Colors.white)),
        content: Text(
          "O gatinho bateu demais nas paredes 😿",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              reiniciarJogo();
            },
            child: Text("Recomeçar"),
          ),
        ],
      ),
    );
  }

  void venceuJogo() {
    cronometro?.cancel();

    jogoIniciado = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("🎉 Você venceu!", style: TextStyle(color: Colors.white)),
        content: Text(
          "Passos: $passosDados",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              avancarFase();
            },
            child: Text("Próximo nível"),
          ),
        ],
      ),
    );
  }

  void avancarFase() {
    setState(() {
      nivelAtual++;

      if (nivelAtual % 5 == 0) {
        tamanhoAtualDaMatriz += 2;
      }

      tempoRestante = max(5, 40 - (nivelAtual));

      passosDados = 0;

      posicaopersonagemX = 1;
      posicaopersonagemY = 1;

      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
    });

    iniciarJogo();
  }

  void moverComBotao(int movimentoX, int movimentoY) {
    if (!jogoIniciado) return;

    int proximoX = posicaopersonagemX + movimentoX;

    int proximoY = posicaopersonagemY + movimentoY;

    if (proximoY >= 0 &&
        proximoY < mapaDoLabirinto.length &&
        proximoX >= 0 &&
        proximoX < mapaDoLabirinto[0].length) {
      // BATEU NA PAREDE
      if (mapaDoLabirinto[proximoY][proximoX] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            duration: Duration(milliseconds: 700),
            content: Text(
              "💥 Você bateu na parede! -1 vida",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        setState(() {
          vidas--;
        });

        if (vidas <= 0) {
          perdeuPorVidas();
        }

        return;
      }

      // MOVIMENTO NORMAL
      setState(() {
        posicaopersonagemX = proximoX;
        posicaopersonagemY = proximoY;

        passosDados++;
      });

      // VITÓRIA
      if (mapaDoLabirinto[proximoY][proximoX] == 3) {
        venceuJogo();
      }
    }
  }

  bool estaVisivel(int x, int y) {
    int distancia =
        (x - posicaopersonagemX).abs() + (y - posicaopersonagemY).abs();

    return distancia <= raioDeVisao;
  }

  @override
  Widget build(BuildContext context) {
    int totalDeLinhas = mapaDoLabirinto.length;

    int totalDeColunas = mapaDoLabirinto[0].length;

    return Scaffold(
      backgroundColor: Color(0xFF121212),

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // TOPO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    // NIVEL
                    Column(
                      children: [
                        Text(
                          "🏆 Nível",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "$nivelAtual",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),

                    // TEMPO
                    Column(
                      children: [
                        Text(
                          "⏳ Tempo",
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "$tempoRestante s",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),

                    // VIDAS
                    Column(
                      children: [
                        Text(
                          "❤️ Vidas",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "$vidas",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // LABIRINTO
            Padding(
              padding: const EdgeInsets.all(10),
              // 🔽 ADICIONE ESTE WIDGET ENVOLVENDO O ASPECT RATIO:
              child: GestureDetector(
                onPanUpdate:
                    _tratarDeslize, // Ativa a nossa função ao arrastar o dedo
                child: AspectRatio(
                  aspectRatio: totalDeColunas / totalDeLinhas,

                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: totalDeColunas,
                    ),

                    itemCount: totalDeLinhas * totalDeColunas,

                    itemBuilder: (context, index) {
                      int x = index % totalDeColunas;

                      int y = index ~/ totalDeColunas;

                      if (!estaVisivel(x, y)) {
                        return Container(
                          margin: EdgeInsets.all(1),

                          decoration: BoxDecoration(
                            color: Colors.black,

                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }

                      int valor = mapaDoLabirinto[y][x];

                      String imagemAtual = "assets/images/chao.png";

                      if (valor == 1) {
                        imagemAtual = "assets/images/parede.png";
                      }

                      if (valor == 3) {
                        imagemAtual = "assets/images/meta.png";
                      }

                      Widget conteudo = SizedBox();

                      // PERSONAGEM
                      if (x == posicaopersonagemX && y == posicaopersonagemY) {
                        conteudo = Icon(
                          Icons.pets,
                          color: Colors.orange,
                          size: 24,
                        );
                      }
                      // OBJETIVO
                      else if (valor == 3) {
                        conteudo = Text("🧶", style: TextStyle(fontSize: 22));
                      }

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),

                        margin: EdgeInsets.all(1),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),

                          image: DecorationImage(
                            image: AssetImage(imagemAtual),
                            fit: BoxFit.cover,
                          ),
                        ),

                        child: Center(child: conteudo),
                      );
                    },
                  ),
                ),
              ),
            ),
            // PASSOS
            Text(
              "👟 Passos: $passosDados",

              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

            // CONTROLES
            Column(
              children: [
                IconButton(
                  iconSize: 60,

                  color: Colors.white,

                  icon: Icon(Icons.keyboard_arrow_up),

                  onPressed: () => moverComBotao(0, -1),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    IconButton(
                      iconSize: 60,

                      color: Colors.white,

                      icon: Icon(Icons.keyboard_arrow_left),

                      onPressed: () => moverComBotao(-1, 0),
                    ),

                    SizedBox(width: 40),

                    IconButton(
                      iconSize: 60,

                      color: Colors.white,

                      icon: Icon(Icons.keyboard_arrow_right),

                      onPressed: () => moverComBotao(1, 0),
                    ),
                  ],
                ),

                IconButton(
                  iconSize: 60,

                  color: Colors.white,

                  icon: Icon(Icons.keyboard_arrow_down),

                  onPressed: () => moverComBotao(0, 1),
                ),
              ],
            ),

            // BOTÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                ElevatedButton.icon(
                  onPressed: jogoIniciado ? null : iniciarJogo,

                  icon: Icon(Icons.play_arrow),

                  label: Text("START"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,

                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),

                SizedBox(width: 20),

                ElevatedButton.icon(
                  onPressed: reiniciarJogo,

                  icon: Icon(Icons.refresh),

                  label: Text("RESTART"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,

                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
