import 'package:flutter/material.dart';

import 'dart:async'; //Biblioteca para usar o Timer!



// Transformamos o StatelessWidget em StatefulWidget para o jogo ter "memória".
class homePageEstado extends StatefulWidget {
  @override
  _TelaDoJogoState createState() => _TelaDoJogoState();
}

// O "State" guarda as informações que mudam durante o jogo.
class _TelaDoJogoState extends State<homePageEstado> {
  // 1. A Matriz de Memória (false = não visitado, true = já visitado)
  late List<List<bool>> lugaresVisitados;
  // A MATRIZ do labirinto (igual à aula 2).
  final List<List<int>> mapaDoLabirinto = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 0, 0, 1, 0, 0, 0, 0, 1],
    [1, 1, 1, 0, 1, 0, 1, 1, 0, 1],
    [1, 0, 0, 0, 1, 0, 1, 0, 0, 1],
    [1, 0, 1, 1, 1, 0, 1, 0, 1, 1],
    [1, 0, 1, 0, 0, 0, 1, 0, 1, 1],
    [1, 0, 1, 0, 1, 1, 1, 0, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 3, 1],
  ];

  // Guardamos o ponto de partida original para o botão Restart
  final int pontoDePartidaX = 1;
  final int pontoDePartidaY = 1;

  // Variáveis mutáveis do estado atual
  int posicaoPersonagemX = 1;
  int posicaoPersonagemY = 1;

  // O jogo só começa quando o aluno apertar o Start!
  bool jogoIniciado = false;

  // 2. NOVAS VARIÁVEIS DE PONTUAÇÃO E TEMPO
  int passosDados = 0;
  int tempoDecorrido = 0;
  Timer?
  cronometro; // O '?' significa que ele pode ser nulo antes do jogo começar

  @override
  void initState() {
    super.initState();
    // Inicializamos a memória com 'false' do mesmo tamanho do mapa
    lugaresVisitados = List.generate(
      mapaDoLabirinto.length,
      (i) => List.filled(mapaDoLabirinto[0].length, false),
    );
  }

  // 2. O CÉREBRO DA IA: Função com Backtracking
  // Usamos "Future<bool>" e "async" para poder dar pequenas pausas e vermos a IA pensando.
  Future<bool> resolverLabirinto(int x, int y) async {
    // CASO BASE: A IA achou a saída (3)?
    if (mapaDoLabirinto[y][x] == 3) return true;

    // Marca o bloco atual como visitado para não voltar aqui
    lugaresVisitados[y][x] = true;

    // Atualiza a posição do personagem na tela e dá uma pausa de meio segundo
    setState(() {
      posicaoPersonagemX = x;
      posicaoPersonagemY = y;
    });
    await Future.delayed(
      Duration(milliseconds: 300),
    ); // A Mágica visual acontece aqui!

    // Para onde a IA pode tentar ir? (Direita, Baixo, Esquerda, Cima)
    List<List<int>> direcoes = [
      [1, 0],
      [0, 1],
      [-1, 0],
      [0, -1],
    ];

    for (var direcao in direcoes) {
      int proximoX = x + direcao[0];
      int proximoY = y + direcao[1];

      // A IA verifica: Está dentro do mapa? Não é parede (1)? E eu ainda não visitei?
      if (proximoY >= 0 &&
          proximoY < mapaDoLabirinto.length &&
          proximoX >= 0 &&
          proximoX < mapaDoLabirinto[0].length &&
          mapaDoLabirinto[proximoY][proximoX] != 1 &&
          lugaresVisitados[proximoY][proximoX] == false) {
        // A IA dá um passo a frente (chamada recursiva)
        bool encontrouSaida = await resolverLabirinto(proximoX, proximoY);

        if (encontrouSaida) return true; // Se achou, repassa a boa notícia!
      }
    }

    // BACKTRACKING: Se chegou aqui, é um beco sem saída. A IA volta (retrocede).
    return false;
  }

  // Nova função para calcular e validar o movimento (Coloque dentro de _TelaDoJogoState)
  void moverPersonagem(DragUpdateDetails detalhes) {
    int movimentoX = 0;
    int movimentoY = 0;

    // Lógica para descobrir se o deslize foi na horizontal ou vertical
    if (detalhes.delta.dx.abs() > detalhes.delta.dy.abs()) {
      // Horizontal: Direita (+1) ou Esquerda (-1)
      movimentoX = detalhes.delta.dx > 0 ? 1 : -1;
    } else {
      // Vertical: Baixo (+1) ou Cima (-1)
      movimentoY = detalhes.delta.dy > 0 ? 1 : -1;
    }

    // Calculamos qual seria a PRÓXIMA posição do personagem
    int proximoX = posicaoPersonagemX + movimentoX;
    int proximoY = posicaoPersonagemY + movimentoY;

    // 1. PREVENÇÃO DE ERROS: O personagem não pode sair da tela.
    if (proximoY >= 0 &&
        proximoY < mapaDoLabirinto.length &&
        proximoX >= 0 &&
        proximoX < mapaDoLabirinto[0].length) {
      // 2. LÓGICA DE COLISÃO: Verificamos se a próxima posição NÃO é uma parede (1).
      if (mapaDoLabirinto[proximoY][proximoX] != 1) {
        // O setState é o comando que avisa o Flutter: "Os dados mudaram, redesenhe a tela!"
        setState(() {
          posicaoPersonagemX = proximoX;
          posicaoPersonagemY = proximoY;
        });
      } else {
        // 3. FEEDBACK DO SISTEMA: Se for parede, avisamos o jogador!
        ScaffoldMessenger.of(context).clearSnackBars(); // Limpa avisos antigos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ops! Bateu na parede."),
            duration: Duration(milliseconds: 500), // Some rápido da tela
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Função do botão START
  void iniciarJogo() {
    setState(() {
      jogoIniciado = true;
    });
    // Inicia um relógio que roda a cada 1 segundo
    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        tempoDecorrido++;
      });
    });
  }

  // Função do botão RESTART
  void reiniciarJogo() {
    cronometro?.cancel(); // Para o relógio se ele estiver rodando

    setState(() {
      posicaoPersonagemX = 1; // Volta pro início
      posicaoPersonagemY = 1;
      jogoIniciado = false;
      passosDados = 0; // Zera a pontuação
      tempoDecorrido = 0; // Zera o tempo
    });
  }

  void venceuJogo() {
    cronometro?.cancel(); // Para o tempo
    jogoIniciado = false; // Trava os controles

    // Mostra um alerta de vitória na tela
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("🎉 Você Escapou!"),
        content: Text("Tempo: $tempoDecorrido segundos\nPassos: $passosDados"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o aviso
              reiniciarJogo(); // Recomeça
            },
            child: Text("Jogar Novamente"),
          ),
        ],
      ),
    );
  }

  // Nova Lógica de Movimento por Botões
  void moverComBotao(int movimentoX, int movimentoY) {
    if (jogoIniciado == false) return;

    int proximoX = posicaoPersonagemX + movimentoX;
    int proximoY = posicaoPersonagemY + movimentoY;

    if (proximoY >= 0 &&
        proximoY < mapaDoLabirinto.length &&
        proximoX >= 0 &&
        proximoX < mapaDoLabirinto[0].length) {
      if (mapaDoLabirinto[proximoY][proximoX] != 1) {
        setState(() {
          posicaoPersonagemX = proximoX;
          posicaoPersonagemY = proximoY;
          passosDados++; // Soma +1 na pontuação de passos
        });

        // 4. VERIFICAÇÃO DE VITÓRIA: Chegou no 3?
        if (mapaDoLabirinto[proximoY][proximoX] == 3) {
          venceuJogo();
        }
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bateu na parede!"),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDeLinhas = mapaDoLabirinto.length;
    int totalDeColunas = mapaDoLabirinto[0].length;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        // Protege contra o "notch" da câmera do celular
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Espalha os itens na tela
          children: [
            // 1. O PLACAR (HUD)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "⏱️ Tempo: $tempoDecorrido s",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "👟 Passos: $passosDados",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 2. O LABIRINTO (Nossa grade antiga, agora menorzinha na parte de cima)
            Padding(
              padding: const EdgeInsets.all(8.0),
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

                    int valor = mapaDoLabirinto[y][x];
                    Color cor = Colors.white;
                    if (valor == 1) cor = Colors.grey;
                    if (valor == 3) cor = Colors.green;
                    if (x == posicaoPersonagemX && y == posicaoPersonagemY)
                      cor = Colors.blue;

                    return Container(margin: EdgeInsets.all(1), color: cor);
                  },
                ),
              ),
            ),
            // 3. PAINEL DE CONTROLE: START E RESTART
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: jogoIniciado
                      ? null
                      : iniciarJogo, // Desabilita se já começou
                  icon: Icon(Icons.play_arrow),
                  label: Text("START"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(width: 20), // Espacinho entre os botões
                ElevatedButton.icon(
                  onPressed: reiniciarJogo,
                  icon: Icon(Icons.refresh),
                  label: Text("RESTART"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            // 4. O D-PAD (Controles Direcionais)
            // Desenhamos uma cruz usando uma Coluna e Linhas
            Column(
              children: [
                // Botão CIMA (Y - 1)
                IconButton(
                  iconSize: 50,
                  color: Colors.white,
                  icon: Icon(Icons.arrow_circle_up),
                  onPressed: () => moverComBotao(0, -1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão ESQUERDA (X - 1)
                    IconButton(
                      iconSize: 50,
                      color: Colors.white,
                      icon: Icon(Icons.arrow_circle_left),
                      onPressed: () => moverComBotao(-1, 0),
                    ),
                    SizedBox(width: 50), // Espaço do meio da cruz
                    // Botão DIREITA (X + 1)
                    IconButton(
                      iconSize: 50,
                      color: Colors.white,
                      icon: Icon(Icons.arrow_circle_right),
                      onPressed: () => moverComBotao(1, 0),
                    ),
                  ],
                ),
                // Botão BAIXO (Y + 1)
                IconButton(
                  iconSize: 50,
                  color: Colors.white,
                  icon: Icon(Icons.arrow_circle_down),
                  onPressed: () => moverComBotao(0, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 1. REFATORAÇÃO: Criamos um Widget focado APENAS em desenhar os blocos
class BlocoLabirinto extends StatelessWidget {
  final Color cor;

  // Construtor que exige uma cor na hora de criar a pecinha de LEGO
  BlocoLabirinto({required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(
          4,
        ), // Um leve arredondamento para ficar mais bonito!
      ),
    );
  }
}

