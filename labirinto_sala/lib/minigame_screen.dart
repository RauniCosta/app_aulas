import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'home_screen.dart';

class MinigameScreen extends StatefulWidget {
  const MinigameScreen({super.key});
  @override
  State<MinigameScreen> createState() => _MinigameScreenState();
}

class _MinigameScreenState extends State<MinigameScreen>
    with WidgetsBindingObserver {
  // ─────────────────────────────────────────────
  // LABIRINTO 11x11 PRÉ-DEFINIDO (ZIG-ZAG)
  // 0 = caminho, 1 = parede, 2 = início, 3 = chegada
  //
  // Sentido de percurso:
  //   Linha 1  (y=1):  x=1 → x=9   (direita)
  //   Descer   (x=9):  y=1 → y=3
  //   Linha 3  (y=3):  x=9 → x=1   (esquerda)
  //   Descer   (x=1):  y=3 → y=5
  //   Linha 5  (y=5):  x=1 → x=9   (direita)
  //   Descer   (x=9):  y=5 → y=7
  //   Linha 7  (y=7):  x=9 → x=1   (esquerda)
  //   Descer   (x=1):  y=7 → y=9
  //   Linha 9  (y=9):  x=1 → x=9   (direita) → chegada em x=9,y=9
  // ─────────────────────────────────────────────
  final List<List<int>> _mapa = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // y=0
    [1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1], // y=1  início (1,1) → direita
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1], // y=2  descida direita (x=9)
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], // y=3  esquerda
    [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1], // y=4  descida esquerda (x=1)
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], // y=5  direita
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1], // y=6  descida direita (x=9)
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], // y=7  esquerda
    [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1], // y=8  descida esquerda (x=1)
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1], // y=9  direita → chegada (9,9)
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // y=10
  ];

  // ─── Células que correspondem às DESCIDAS do zig-zag ──────────────────────
  // São as células onde o jogador literalmente entra na coluna vertical,
  // conforme anotado nos comentários de _mapa acima.
  //   (9,2) → descida direita  y=1→y=3
  //   (1,4) → descida esquerda y=3→y=5
  //   (9,6) → descida direita  y=5→y=7
  //   (1,8) → descida esquerda y=7→y=9
  static const List<List<int>> _celulasDesdida = [
    [9, 2],
    [1, 4],
    [9, 6],
    [1, 8],
  ];

  bool _ehCelulaDescida(int x, int y) =>
      _celulasDesdida.any((c) => c[0] == x && c[1] == y);

  bool _ultimaDescida = false;

  bool _ehUltimaDescida(int x, int y) {
    // Se nem for uma célula de descida, já retorna falso
    if (!_ehCelulaDescida(x, y)) return false;

    int indiceAtual = _indiceNaOrdem(x, y);

    // Verifica se não existe nenhuma outra célula de descida com um índice maior
    return !_celulasDesdida.any((c) {
      int maxIndice = _indiceNaOrdem(c[0], c[1]);
      return maxIndice > indiceAtual;
    });
  }

  // Posição do jogador
  int _jogX = 1;
  int _jogY = 1;

  bool _jogoIniciado = false;
  bool _jogoEncerrado = false;
  bool _jogadorVisivel = true;
  bool _springlockAtivada =
      false; // true após chegar, mostra springlock_purple_guy
  bool _springlockMorte = false; // true após 5s, mostra springlock_die
  bool _purpleGuyDireita = true;
  bool _primeiroMovimento = true;

  // ─── Crying children (5 instâncias) ───────────
  // Índice 0 = mais próxima do jogador (na frente da fila)
  // Armazenamos o ÍNDICE na _ordemPercurso, não as coordenadas XY diretamente.
  // -1 significa "ainda não entrou no mapa".
  late List<int> _cryIndices; // substitui _cryX / _cryY

  // Ordem de percurso (lista de células [x,y] na sequência do zig-zag)
  late List<List<int>> _ordemPercurso;

  // Índice do jogador na ordem de percurso
  int _jogadorIndice = 0;

  // ─── Áudio ────────────────────────────────────
  final AudioPlayer musicaPlayer = AudioPlayer();
  final AudioPlayer _playerSorriso = AudioPlayer();
  final AudioPlayer _playerSpringlock = AudioPlayer();

  // ─── Sorteio do número da Night no HUD ────────
  int _nightDisplay = 1;
  int _timeDisplay = 1;
  Timer? _timerSorteioNight;
  Timer? _timerSorteioTime;
  final Random _random = Random();

  Timer? _timerCryingChildren;

  // ─── Controle de gesto ────────────────────────
  bool _gestoProcessado = false;

  final AudioPlayer _playerDirecao = AudioPlayer();
  final AudioPlayer _playerPassos = AudioPlayer();

  final AssetSource _somDirecao = AssetSource('audios/mudando_direcao.ogg');
  final AssetSource _somPassos = AssetSource('audios/purple_guy_passos.ogg');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _construirOrdemPercurso();
    _inicializarCryingChildren();
    _iniciarSorteioNight();
    _iniciarSorteioTime();
    _gerenciarMusicaAmbiente();
  }

  @override
  void dispose() {
    _timerCryingChildren?.cancel();
    _timerSorteioNight?.cancel();
    _timerSorteioTime?.cancel();
    musicaPlayer.dispose();
    _playerSpringlock.dispose();
    _playerDirecao.dispose();
    _playerPassos.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      musicaPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      musicaPlayer.resume();
    }
  }

  Future<void> _gerenciarMusicaAmbiente() async {
    await musicaPlayer.stop();
    await musicaPlayer.setReleaseMode(ReleaseMode.loop);
    await musicaPlayer.play(AssetSource('audios/minigame.ogg'), volume: 0.1);
  }

  // ─────────────────────────────────────────────
  // Constrói a lista ordenada de células do percurso
  // ─────────────────────────────────────────────
  void _construirOrdemPercurso() {
    _ordemPercurso = [];

    // Linha 1: x=1..9, y=1
    for (int x = 1; x <= 9; x++) {
      _ordemPercurso.add([x, 1]);
    }
    // Descer: x=9, y=2..3
    for (int y = 2; y <= 3; y++) {
      _ordemPercurso.add([9, y]);
    }
    // Linha 3: x=8..1, y=3
    for (int x = 8; x >= 1; x--) {
      _ordemPercurso.add([x, 3]);
    }
    // Descer: x=1, y=4..5
    for (int y = 4; y <= 5; y++) {
      _ordemPercurso.add([1, y]);
    }
    // Linha 5: x=2..9, y=5
    for (int x = 2; x <= 9; x++) {
      _ordemPercurso.add([x, 5]);
    }
    // Descer: x=9, y=6..7
    for (int y = 6; y <= 7; y++) {
      _ordemPercurso.add([9, y]);
    }
    // Linha 7: x=8..1, y=7
    for (int x = 8; x >= 1; x--) {
      _ordemPercurso.add([x, 7]);
    }
    // Descer: x=1, y=8..9
    for (int y = 8; y <= 9; y++) {
      _ordemPercurso.add([1, y]);
    }
    // Linha 9: x=2..9, y=9
    for (int x = 2; x <= 9; x++) {
      _ordemPercurso.add([x, 9]);
    }
  }

  // Inicializa as 5 crying children fora do mapa (índice -1)
  void _inicializarCryingChildren() {
    _cryIndices = List.filled(5, -1);
  }

  // Retorna o índice na ordem de percurso para uma dada posição (ou -1 se não encontrar)
  int _indiceNaOrdem(int x, int y) {
    for (int i = 0; i < _ordemPercurso.length; i++) {
      if (_ordemPercurso[i][0] == x && _ordemPercurso[i][1] == y) return i;
    }
    return -1;
  }

  void _iniciarSorteioNight() {
    _timerSorteioNight = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;

      int novoNumero;
      do {
        novoNumero = _random.nextInt(7) + 1; // Sorteia de 1 a 7
      } while (novoNumero ==
          _nightDisplay); // Repete se for igual ao que já está na tela

      setState(() {
        _nightDisplay = novoNumero;
      });
    });
  }

  void _iniciarSorteioTime() {
    _timerSorteioTime = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;

      int novoNumero;
      do {
        novoNumero = _random.nextInt(6) + 1; // Sorteia de 1 a 6
      } while (novoNumero == _timeDisplay); // Repete se for igual ao anterior

      setState(() {
        _timeDisplay = novoNumero;
      });
    });
  }

  // ─────────────────────────────────────────────
  // MOVER JOGADOR
  // ─────────────────────────────────────────────
  void _moverJogador(int dx, int dy) {
    if (!_jogoIniciado || _jogoEncerrado) return;

    if (_primeiroMovimento) {
      _primeiroMovimento = false;
      _purpleGuyDireita = false;
    }

    int novoX = _jogX + dx;
    int novoY = _jogY + dy;

    if (novoY < 0 || novoY >= 11 || novoX < 0 || novoX >= 11) return;
    if (_mapa[novoY][novoX] == 1) return;

    int novoIndice = _indiceNaOrdem(novoX, novoY);
    if (novoIndice < _jogadorIndice) return;

    // Impede andar para a célula que a criança mais próxima ocupa
    if (_cryIndices[0] != -1 &&
        _ordemPercurso[_cryIndices[0]][0] == novoX &&
        _ordemPercurso[_cryIndices[0]][1] == novoY) {
      return;
    }

    // ── SOM DE MUDANÇA DE DIREÇÃO ──
    // Toca APENAS quando o jogador entra numa célula de descida
    if (_ehCelulaDescida(novoX, novoY)) {
      _playerDirecao.stop();
      _playerDirecao.play(_somDirecao, volume: 0.05);
      _purpleGuyDireita = !_purpleGuyDireita;
    }

    if (_ehUltimaDescida(novoX, novoY)) {
      _ultimaDescida = true;
    }

    // ── SOM DE PASSO ──
    _playerPassos.seek(Duration.zero);
    _playerPassos.play(_somPassos, volume: 0.05);

    setState(() {
      _jogX = novoX;
      _jogY = novoY;
      _jogadorIndice = novoIndice;
    });

    if (_mapa[novoY][novoX] == 3) {
      _ativarSpringlock();
    }
  }

  void _iniciarTimerCryingChildren() {
    _timerCryingChildren?.cancel();

    _timerCryingChildren = Timer.periodic(const Duration(milliseconds: 250), (
      _,
    ) {
      if (!mounted || !_jogoIniciado) return;

      setState(() {
        _atualizarCryingChildren();
      });
    });
  }

  // ─────────────────────────────────────────────
  // ATUALIZAR CRYING CHILDREN
  //
  // Correção do "teleporte":
  //   Antes, cada criança era identificada por coordenadas XY e recalculava
  //   seu índice a cada tick. O problema era que processar a criança 0 primeiro
  //   (ela já avançou) e depois calcular o limite da criança 1 com base na
  //   posição nova da 0 causava um "achatamento" da fila — visualmente, a
  //   última criança parecia pular para frente.
  //
  //   Agora usamos _cryIndices (índice direto em _ordemPercurso) e calculamos
  //   TODOS os alvos com base nos índices ANTES de mover qualquer criança.
  //   Só após calcular todos os novos índices aplicamos o setState de uma vez.
  // ─────────────────────────────────────────────
  void _atualizarCryingChildren() {
    // 1. Calcula os índices-alvo com base nos valores ATUAIS (snapshot)
    final List<int> snapshot = List.of(_cryIndices); // cópia imutável

    final List<int> novosIndices = List.of(_cryIndices);

    for (int i = 0; i < 5; i++) {
      int idxAlvo;
      if (i == 0) {
        // Criança 0 persegue o jogador, para 1 quadrado antes
        idxAlvo = _jogadorIndice - 1;
      } else {
        // Criança i persegue a criança i-1 (usando o snapshot, antes de mover)
        int idxFrente = snapshot[i - 1];
        idxAlvo = idxFrente - 1;
      }

      // Ainda não pode entrar (jogador não andou o suficiente)
      if (idxAlvo < 0) continue;

      int idxAtual = snapshot[i];

      if (idxAtual == -1) {
        // Nasce na primeira posição do percurso
        novosIndices[i] = 0;
      } else if (idxAtual < idxAlvo) {
        // Dá um único passo para frente
        novosIndices[i] = idxAtual + 1;
      }
      // Se idxAtual >= idxAlvo, fica parada
    }

    // 2. Aplica todos os novos índices de uma vez
    _cryIndices = novosIndices;
  }

  // ─────────────────────────────────────────────
  // CHEGADA: sequência springlock
  // ─────────────────────────────────────────────
  Future<void> _ativarSpringlock() async {
    if (_jogoEncerrado) return;
    setState(() {
      _jogoEncerrado = true;
      _jogadorVisivel = false;
      _springlockAtivada = true;
    });

    for (int i = 0; i < 5; i++) {
      await _playerSorriso.play(
        AssetSource('audios/sorriso.ogg'),
        volume: 0.05,
      );
      await _playerSorriso.onPlayerComplete.first;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    await _playerSpringlock.play(
      AssetSource('audios/springlock_die.ogg'),
      volume: 0.05,
    );

    setState(() {
      _springlockAtivada = false;
      _springlockMorte = true;
    });

    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    _playerSpringlock.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  // ─────────────────────────────────────────────
  // GESTO DE DESLIZE
  // ─────────────────────────────────────────────
  // Depois:
  void _moverPorGesto(DragUpdateDetails d) {
    if (!_jogoIniciado || _gestoProcessado) return;
    const double sens = 8.0;
    double dx = d.delta.dx;
    double dy = d.delta.dy;

    if (dx.abs() > dy.abs()) {
      if (dx.abs() > sens) {
        int dirX = dx > 0 ? 1 : -1;
        if (!_movimentoValido(dirX, 0)) return;
        _gestoProcessado = true;
        _moverJogador(dirX, 0);
      }
    } else {
      if (dy.abs() > sens) {
        int dirY = dy > 0 ? 1 : -1;
        if (!_movimentoValido(0, dirY)) return;
        _gestoProcessado = true;
        _moverJogador(0, dirY);
      }
    }
  }

  bool _movimentoValido(int dx, int dy) {
    if (!_jogoIniciado || _jogoEncerrado) return false;

    int novoX = _jogX + dx;
    int novoY = _jogY + dy;

    // Fora dos limites
    if (novoY < 0 || novoY >= 11 || novoX < 0 || novoX >= 11) return false;
    // Parede
    if (_mapa[novoY][novoX] == 1) return false;
    // Andando para trás
    int novoIndice = _indiceNaOrdem(novoX, novoY);
    if (novoIndice < _jogadorIndice) return false;
    // Bloqueado pela crying child mais próxima
    if (_cryIndices[0] != -1 &&
        _ordemPercurso[_cryIndices[0]][0] == novoX &&
        _ordemPercurso[_cryIndices[0]][1] == novoY) {
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const int totalLinhas = 11;
    const int totalColunas = 11;

    // Monta um Set rápido de posições das crying children para lookup O(1)
    // Chave: x * 100 + y  (funciona para mapas menores que 100)
    final Set<int> cryPos = {};
    for (int i = 0; i < 5; i++) {
      if (_cryIndices[i] != -1) {
        final cell = _ordemPercurso[_cryIndices[i]];
        cryPos.add(cell[0] * 100 + cell[1]);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090011),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF12001F), Color(0xFF090011), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── CABEÇALHO ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              _playerSpringlock.stop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                              );
                            },
                          ),
                        ),
                        Image.asset(
                          'assets/images/fazbear_maze.webp',
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),

                  // ── LABIRINTO ──────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purpleAccent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withValues(
                                  alpha: 0.6,
                                ),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.pinkAccent.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onPanUpdate: _moverPorGesto,
                            onPanEnd: (_) => _gestoProcessado = false,
                            child: AspectRatio(
                              aspectRatio: totalColunas / totalLinhas,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: totalColunas,
                                      ),
                                  itemCount: totalLinhas * totalColunas,
                                  itemBuilder: (context, index) {
                                    int x = index % totalColunas;
                                    int y = index ~/ totalColunas;
                                    int valor = _mapa[y][x];

                                    BoxDecoration decoracao;
                                    Widget? filhoCelula;

                                    // Parede
                                    if (valor == 1) {
                                      decoracao = BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF3C006F),
                                            Color(0xFF1A0033),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(
                                          color: Colors.purpleAccent.withValues(
                                            alpha: 0.7,
                                          ),
                                          width: 0.8,
                                        ),
                                      );
                                    }
                                    // Chegada
                                    else if (valor == 3) {
                                      decoracao = BoxDecoration(
                                        color: const Color(0xFF0D0D13),
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 0.5,
                                        ),
                                      );
                                      String springlockImg = _springlockMorte
                                          ? 'assets/images/springlock_die.webp'
                                          : _springlockAtivada
                                          ? 'assets/images/springlock_purple_guy.webp'
                                          : 'assets/images/springlock.webp';
                                      filhoCelula = Image.asset(
                                        springlockImg,
                                        fit: BoxFit.contain,
                                      );
                                    }
                                    // Caminho vazio / início
                                    else {
                                      decoracao = BoxDecoration(
                                        color: const Color(0xFF0D0D13),
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 0.5,
                                        ),
                                      );
                                    }

                                    // Crying children (usa o Set pré-computado)
                                    if (cryPos.contains(x * 100 + y)) {
                                      filhoCelula = Image.asset(
                                        'assets/images/crying_child.webp',
                                        fit: BoxFit.contain,
                                      );
                                      decoracao = BoxDecoration(
                                        color: const Color(0xFF0D0D13),
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 0.5,
                                        ),
                                      );
                                    }

                                    // Jogador (por cima de tudo)
                                    if (x == _jogX &&
                                        y == _jogY &&
                                        _jogadorVisivel) {
                                      filhoCelula = Image.asset(
                                        _primeiroMovimento
                                            ? 'assets/images/purple_guy.webp'
                                            : _ultimaDescida
                                            ? 'assets/images/purple_guy_sorrindo.webp'
                                            : _purpleGuyDireita
                                            ? 'assets/images/purple_guy_direita.webp'
                                            : 'assets/images/purple_guy_esquerda.webp',
                                        fit: BoxFit.contain,
                                      );
                                      decoracao = BoxDecoration(
                                        color: const Color(0xFF0D0D13),
                                        border: Border.all(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 0.5,
                                        ),
                                      );
                                    }

                                    return Container(
                                      margin: const EdgeInsets.all(0.5),
                                      decoration: decoracao,
                                      child: filhoCelula,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── HUD ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _hudTexto("NIGHT", "$_nightDisplay"),
                        _hudTexto("SIZE", "11x11"),
                        _hudTexto("TIME", "$_timeDisplay AM"),
                      ],
                    ),
                  ),

                  // ── BOTÕES + D-PAD ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botões Start / Reset
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: (_jogoIniciado || _jogoEncerrado)
                                  ? null
                                  : () {
                                      setState(() {
                                        _jogoIniciado = true;
                                      });
                                      _iniciarTimerCryingChildren();
                                    },
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text("START"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text("RESET"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // D-PAD ou "PRESS START"
                        if (_jogoIniciado) ...[
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: _controleBotao(
                                    Icons.keyboard_arrow_up,
                                    _movimentoValido(0, -1)
                                        ? () => _moverJogador(0, -1)
                                        : null,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _controleBotao(
                                    Icons.keyboard_arrow_left,
                                    _movimentoValido(-1, 0)
                                        ? () => _moverJogador(-1, 0)
                                        : null,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _controleBotao(
                                    Icons.keyboard_arrow_right,
                                    _movimentoValido(1, 0)
                                        ? () => _moverJogador(1, 0)
                                        : null,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _controleBotao(
                                    Icons.keyboard_arrow_down,
                                    _movimentoValido(0, 1)
                                        ? () => _moverJogador(0, 1)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Center(
                              child: Text(
                                _jogoEncerrado ? "" : "PRESS START",
                                style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/images/springtrap_maze.webp',
                  height: 1000,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS AUXILIARES
  // ─────────────────────────────────────────────
  // Depois:
  Widget _controleBotao(IconData icone, VoidCallback? onPressed) {
    final bool habilitado = onPressed != null;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: habilitado ? const Color(0xFF240046) : const Color(0xFF2A2A2A),
        boxShadow: habilitado
            ? [
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ]
            : [],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 28,
        color: habilitado ? Colors.white : Colors.grey.shade600,
        icon: Icon(icone),
        onPressed: onPressed,
      ),
    );
  }

  Widget _hudTexto(String titulo, String valor) {
    return Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
          ),
        ),
      ],
    );
  }
}
