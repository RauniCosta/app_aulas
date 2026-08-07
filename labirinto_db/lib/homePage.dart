import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaDoJogo extends StatefulWidget {
  const TelaDoJogo({super.key});

  @override
  _TelaDoJogoState createState() => _TelaDoJogoState();
}

class _TelaDoJogoState extends State<TelaDoJogo> {
  // Matriz e Variáveis de Progressão
  late List<List<int>> mapaDoLabirinto;
  int nivelAtual = 1;
  int tamanhoAtualDaMatriz = 7;

  // Posições e Controles
  int posicaoPersonagemX = 1;
  int posicaoPersonagemY = 1;
  final int pontoDePartidaX = 1;
  final int pontoDePartidaY = 1;
  bool jogoIniciado = false;

  // Pontuação e Status
  int passosDados = 0;
  int tempoDecorrido = 0;
  int batidasNaParede = 0;
  int recordeNivel = 1;

  // Variáveis Coletáveis e Poderes (PAC-MAN)
  int moedasColetadas = 0;
  bool lanternaAtiva = false; 
  int moedasRestantes = 0; 
  bool superPoder = false;

  // Variáveis do Fantasma
  int fantasmaX = 1;
  int fantasmaY = 1;
  Timer? loopFantasma;

  Timer? cronometro;
  final AudioPlayer reprodutorDeAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
    _iniciarMusica();
    _carregarRecorde();
  }

  @override
  void dispose() {
    reprodutorDeAudio.dispose();
    cronometro?.cancel();
    loopFantasma?.cancel(); // Garante que o fantasma para ao sair da tela
    super.dispose();
  }

  void _iniciarMusica() async {
    try {
      await reprodutorDeAudio.setReleaseMode(ReleaseMode.loop);
      // await reprodutorDeAudio.play(AssetSource('musica.mp3')); 
    } catch (e) {
      print("Erro ao carregar música: $e");
    }
  }

  // --- BANCO DE DADOS ---
  void _carregarRecorde() async {
    final bancoDeDados = await SharedPreferences.getInstance();
    setState(() {
      recordeNivel = bancoDeDados.getInt('meuRecorde') ?? 1;
    });
  }

  void _salvarRecorde() async {
    if (nivelAtual > recordeNivel) {
      final bancoDeDados = await SharedPreferences.getInstance();
      await bancoDeDados.setInt('meuRecorde', nivelAtual);
      setState(() {
        recordeNivel = nivelAtual;
      });
    }
  }

  // --- FUNÇÕES DE CONTROLE DE JOGO ---
  void iniciarJogo() {
    setState(() {
      jogoIniciado = true;
    });
    
    // Cronômetro do jogador
    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        tempoDecorrido++;
      });
    });

    // O CÉREBRO DO FANTASMA
    loopFantasma = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (!jogoIniciado) return;

      List<List<int>> direcoes = [[0, -1], [0, 1], [-1, 0], [1, 0]];
      direcoes.shuffle(); 

      for (var dir in direcoes) {
        int tentaX = fantasmaX + dir[0];
        int tentaY = fantasmaY + dir[1];

        // Lógica de Túnel para o Fantasma também
        if (tentaX < 0) tentaX = mapaDoLabirinto[0].length - 1;
        if (tentaX >= mapaDoLabirinto[0].length) tentaX = 0;
        if (tentaY < 0) tentaY = mapaDoLabirinto.length - 1;
        if (tentaY >= mapaDoLabirinto.length) tentaY = 0;

        // Fantasma anda se não for parede
        if (mapaDoLabirinto[tentaY][tentaX] != 1) {
          setState(() {
            fantasmaX = tentaX;
            fantasmaY = tentaY;
          });

          // Fantasma pegou o jogador!
          if (fantasmaX == posicaoPersonagemX && fantasmaY == posicaoPersonagemY) {
            _gameOverFantasma();
          }
          break; 
        }
      }
    });
  }

  void _gameOverFantasma() {
    loopFantasma?.cancel();
    cronometro?.cancel();
    setState(() { jogoIniciado = false; });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("👻 O Fantasma te pegou! Fim de Jogo."), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  void reiniciarJogo() {
    cronometro?.cancel();
    loopFantasma?.cancel();
    
    setState(() {
      nivelAtual = 1;
      tamanhoAtualDaMatriz = 7;
      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
      posicaoPersonagemX = pontoDePartidaX;
      posicaoPersonagemY = pontoDePartidaY;
      jogoIniciado = false;
      passosDados = 0;
      tempoDecorrido = 0;
      batidasNaParede = 0;
      moedasColetadas = 0; 
      lanternaAtiva = false; 
      superPoder = false;
    });
  }

  void avancarNivel() {
    loopFantasma?.cancel(); // Pausa o fantasma antigo
    setState(() {
      nivelAtual++;
      if (nivelAtual % 3 == 0) tamanhoAtualDaMatriz += 2;

      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
      posicaoPersonagemX = pontoDePartidaX;
      posicaoPersonagemY = pontoDePartidaY;

      lanternaAtiva = false; 
      superPoder = false;
      jogoIniciado = false; // Exige apertar START na nova fase
    });
    _salvarRecorde();
  }

  void venceuJogo() {
    cronometro?.cancel();
    loopFantasma?.cancel();
    jogoIniciado = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🎉 Você limpou o mapa! Nível $nivelAtual concluído!"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
    // Dá um tempinho antes de gerar a nova tela
    Timer(Duration(seconds: 2), () {
      avancarNivel();
    });
  }

  // --- LÓGICA DE COLETA NO MOVIMENTO ---
  void _processarMovimento(int proximoX, int proximoY) {
    int valorDoBloco = mapaDoLabirinto[proximoY][proximoX];

    // Se bateu no fantasma
    if (proximoX == fantasmaX && proximoY == fantasmaY) {
      _gameOverFantasma();
      return;
    }

    if (valorDoBloco != 1 || superPoder == true) { 
      
      // Quebrando parede com o poder
      if (valorDoBloco == 1) {
        mapaDoLabirinto[proximoY][proximoX] = 0;
        HapticFeedback.heavyImpact(); 
      }

      // Pegando Moeda (Meta do Jogo)
      if (valorDoBloco == 4) {
        moedasColetadas++;
        moedasRestantes--; 
        HapticFeedback.lightImpact(); 
        mapaDoLabirinto[proximoY][proximoX] = 0; 
        
        if (moedasRestantes == 0) {
          venceuJogo();
        }
      } 
      // Pegando Lanterna
      else if (valorDoBloco == 5) {
        lanternaAtiva = true; 
        HapticFeedback.mediumImpact();
        mapaDoLabirinto[proximoY][proximoX] = 0; 
      }
      // Pegando Pílula do Poder (Estrela)
      else if (valorDoBloco == 6) {
        mapaDoLabirinto[proximoY][proximoX] = 0;
        setState(() { superPoder = true; }); 
        
        Timer(Duration(seconds: 5), () {
          if (mounted) setState(() { superPoder = false; });
        });
      }

      setState(() {
        posicaoPersonagemX = proximoX;
        posicaoPersonagemY = proximoY;
        passosDados++;
      });

    } else {
      _registrarBatida();
    }
  }

  // Túnel Pac-Man implementado
  void _calcularProximaPosicao(int movimentoX, int movimentoY) {
    if (!jogoIniciado) return;

    int proximoX = posicaoPersonagemX + movimentoX;
    int proximoY = posicaoPersonagemY + movimentoY;

    if (proximoX < 0) {
      proximoX = mapaDoLabirinto[0].length - 1; 
    } else if (proximoX >= mapaDoLabirinto[0].length) {
      proximoX = 0; 
    }

    if (proximoY < 0) {
      proximoY = mapaDoLabirinto.length - 1; 
    } else if (proximoY >= mapaDoLabirinto.length) {
      proximoY = 0; 
    }

    _processarMovimento(proximoX, proximoY);
  }

  void moverComBotao(int movimentoX, int movimentoY) {
    _calcularProximaPosicao(movimentoX, movimentoY);
  }

  void moverPersonagem(DragUpdateDetails detalhes) {
    int movimentoX = 0;
    int movimentoY = 0;
    if (detalhes.delta.dx.abs() > detalhes.delta.dy.abs()) {
      movimentoX = detalhes.delta.dx > 0 ? 1 : -1;
    } else {
      movimentoY = detalhes.delta.dy > 0 ? 1 : -1;
    }
    _calcularProximaPosicao(movimentoX, movimentoY);
  }

  void _registrarBatida() {
    setState(() {
      batidasNaParede++;
    });
    HapticFeedback.heavyImpact(); 
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ops! Bateu na parede."),
        duration: Duration(milliseconds: 300),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // --- GERADOR PROCEDURAL ---
  List<List<int>> gerarLabirinto(int tamanho) {
    List<List<int>> novoMapa = List.generate(
      tamanho,
      (_) => List.filled(tamanho, 1),
    );
    Random aleatorio = Random();

    void cavarCaminho(int x, int y) {
      novoMapa[y][x] = 0;
      List<List<int>> direcoes = [[0, -2], [2, 0], [0, 2], [-2, 0]];
      direcoes.shuffle(aleatorio);

      for (var direcao in direcoes) {
        int proximoX = x + direcao[0];
        int proximoY = y + direcao[1];

        if (proximoY > 0 && proximoY < tamanho - 1 &&
            proximoX > 0 && proximoX < tamanho - 1 &&
            novoMapa[proximoY][proximoX] == 1) {
          novoMapa[y + (direcao[1] ~/ 2)][x + (direcao[0] ~/ 2)] = 0;
          cavarCaminho(proximoX, proximoY);
        }
      }
    }

    cavarCaminho(1, 1);
    novoMapa[1][1] = 2; // Início

    // Cava o túnel nas laterais para o efeito Pac-Man
    novoMapa[tamanho ~/ 2][0] = 0;
    novoMapa[tamanho ~/ 2][tamanho - 1] = 0;

    List<List<int>> caminhosVazios = [];
    for (int y = 1; y < tamanho - 1; y++) {
      for (int x = 1; x < tamanho - 1; x++) {
        if (novoMapa[y][x] == 0 && !(x == 1 && y == 1)) {
          caminhosVazios.add([x, y]);
        }
      }
    }

    caminhosVazios.shuffle(aleatorio);

    // Sorteia posição do Fantasma
    if (caminhosVazios.isNotEmpty) {
      var pos = caminhosVazios.removeLast();
      fantasmaX = pos[0];
      fantasmaY = pos[1];
    }

    // Pega 1 posição para a Lanterna (5)
    if (caminhosVazios.isNotEmpty) {
      var pos = caminhosVazios.removeLast();
      novoMapa[pos[1]][pos[0]] = 5;
    }

    // Pega 1 posição para a Pílula do Poder/Estrela (6)
    if (caminhosVazios.isNotEmpty) {
      var pos = caminhosVazios.removeLast();
      novoMapa[pos[1]][pos[0]] = 6;
    }

    // Espalha Moedas (4)
    int quantidadeMoedas = 3 + (tamanho ~/ 2);
    moedasRestantes = quantidadeMoedas; 
    
    for (int i = 0; i < quantidadeMoedas; i++) {
      if (caminhosVazios.isNotEmpty) {
        var pos = caminhosVazios.removeLast();
        novoMapa[pos[1]][pos[0]] = 4;
      }
    }

    return novoMapa;
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _construirLabirinto(),
            _construirPainelStart(),
            _construirHUD(),
            _construirControles(),
          ],
        ),
      ),
    );
  }

  Widget _construirLabirinto() {
    int totalDeLinhas = mapaDoLabirinto.length;
    int totalDeColunas = mapaDoLabirinto[0].length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onPanUpdate: moverPersonagem,
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

              int distanciaX = (x - posicaoPersonagemX).abs();
              int distanciaY = (y - posicaoPersonagemY).abs();

              bool visivel = lanternaAtiva || (distanciaX <= 1 && distanciaY <= 1);

              if (!visivel) {
                return Container(margin: EdgeInsets.all(1), color: Colors.black);
              }

              Color corDaParede = Colors.grey.shade800;
              if (nivelAtual >= 4) corDaParede = Colors.blueGrey.shade900;
              if (nivelAtual >= 8) corDaParede = Colors.purple.shade900;

              // 1. DEFININDO AS TEXTURAS (Caminhos das imagens)
              String? texturaDoBloco; // Pode ser nulo se quisermos usar apenas cor
              Color corDoBloco = Colors.black; // Cor de fundo padrão
              Widget? conteudoDoBloco;

              // Lógica da Parede Dinâmica
              if (valor == 1) {
                if (nivelAtual < 4) {
                  texturaDoBloco = 'assets/parede_pedra.png'; 
                  corDoBloco = Colors.grey.shade800; // Cor de segurança caso a imagem não carregue
                } else if (nivelAtual < 8) {
                  texturaDoBloco = 'assets/parede_lava.png';
                  corDoBloco = Colors.orange.shade900;
                } else {
                  texturaDoBloco = 'assets/parede_magica.png';
                  corDoBloco = Colors.purple.shade900;
                }
              } 
              // Lógica do Caminho Livre
              else {
                texturaDoBloco = 'assets/chao.png'; // Uma textura de terra ou piso
                corDoBloco = Colors.white24;
              }

              // Lógica dos Itens (Emojis sobrepostos à textura do chão)
              if (valor == 3) {
                conteudoDoBloco = Center(child: Text("🏆", style: TextStyle(fontSize: 20)));
              } else if (valor == 4) { 
                conteudoDoBloco = Center(child: Text("🪙", style: TextStyle(fontSize: 16)));
              } else if (valor == 5) { 
                conteudoDoBloco = Center(child: Text("🔦", style: TextStyle(fontSize: 16)));
              } else if (valor == 6) { 
                conteudoDoBloco = Center(child: Text("⭐", style: TextStyle(fontSize: 18)));
              }

              // Fantasma e Jogador
              if (x == fantasmaX && y == fantasmaY) {
                conteudoDoBloco = Center(child: Text("👻", style: TextStyle(fontSize: 20)));
              }
              if (x == posicaoPersonagemX && y == posicaoPersonagemY) {
                conteudoDoBloco = Center(child: Text(superPoder ? "🦾" : "🤖", style: TextStyle(fontSize: 20)));
              }
              
              // 2. APLICANDO A TEXTURA NO BLOCO
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.all(0.5), // Margem menor para os blocos parecerem unidos
                decoration: BoxDecoration(
                  color: corDoBloco,
                  borderRadius: BorderRadius.circular(2), // Bordas mais retas ficam melhores com texturas
                  
                  // A MÁGICA DA TEXTURA ACONTECE AQUI:
                  image: texturaDoBloco != null
                      ? DecorationImage(
                          image: AssetImage(texturaDoBloco),
                          fit: BoxFit.cover, // Faz a imagem preencher todo o quadrado
                        )
                      : null, // Se não tiver textura, usa só a cor
                ),
                child: conteudoDoBloco,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _construirPainelStart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: jogoIniciado ? null : iniciarJogo,
          icon: Icon(Icons.play_arrow),
          label: Text("START"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: reiniciarJogo,
          icon: Icon(Icons.refresh),
          label: Text("RESTART"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
      ],
    );
  }

  Widget _construirHUD() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("🏅 Recorde: Lvl $recordeNivel", style: TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("🪙 Faltam: $moedasRestantes", style: TextStyle(color: Colors.yellowAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("🏆 Nível: $nivelAtual", style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("⏱️ Tempo: $tempoDecorrido s", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("👟 Passos: $passosDados", style: TextStyle(color: Colors.white, fontSize: 18)),
              Text("💥 Erros: $batidasNaParede", style: TextStyle(color: Colors.redAccent, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirControles() {
    return Column(
      children: [
        IconButton(
          iconSize: 50, color: Colors.white,
          icon: Icon(Icons.arrow_circle_up),
          onPressed: () => moverComBotao(0, -1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 50, color: Colors.white,
              icon: Icon(Icons.arrow_circle_left),
              onPressed: () => moverComBotao(-1, 0),
            ),
            SizedBox(width: 50),
            IconButton(
              iconSize: 50, color: Colors.white,
              icon: Icon(Icons.arrow_circle_right),
              onPressed: () => moverComBotao(1, 0),
            ),
          ],
        ),
        IconButton(
          iconSize: 50, color: Colors.white,
          icon: Icon(Icons.arrow_circle_down),
          onPressed: () => moverComBotao(0, 1),
        ),
      ],
    );
  }
}