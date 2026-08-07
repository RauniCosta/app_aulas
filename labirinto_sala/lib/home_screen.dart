import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'maze_screen.dart';
import 'minigame_screen.dart'; // IMPORTAÇÃO DA NOVA TELA
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AudioPlayer playerFreddy = AudioPlayer();
  final AudioPlayer musicaPlayer = AudioPlayer();
  final AudioPlayer playerFucinho = AudioPlayer();
  bool _exibirRuin = false;
  bool _volumeNoMaximo = false;
  int noiteAtual = 1;

  // Contador para o segredo do focinho
  int _cliquesFucinho = 0;

  // Animatrônico selecionado (padrão: freddy)
  String _animatronico = 'freddy';

  // Mapa de cores características por animatrônico
  static const Map<String, Color> _coresAnimatronic = {
    'freddy': Color(0xFFC0673C), // marrom
    'bonnie': Color(0xFF565187), // azul escuro
    'chica': Color(0xFFF9A825), // amarelo
    'foxy': Color(0xFFE64A19), // laranja
  };

  static const Map<String, String> _nomesAnimatronic = {
    'freddy': 'Freddy',
    'bonnie': 'Bonnie',
    'chica': 'Chica',
    'foxy': 'Foxy',
  };

  Color get _corAtual => _coresAnimatronic[_animatronico] ?? Colors.brown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carregarAnimatronico();
    iniciarMusica();
    iniciarEfeitoPiscada();
    _checarVolumeInicial();
    _ouvirMudancasDeVolume();
    _carregarNoiteAtual();
  }

  @override
  void dispose() {
    musicaPlayer.dispose();
    playerFucinho.dispose(); // Boa prática descartar também o player do focinho
    FlutterVolumeController.removeListener();
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
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
      if (isCurrentRoute) {
        musicaPlayer.resume();
      }
    }
  }

  Future<void> _carregarNoiteAtual() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      noiteAtual = prefs.getInt('noiteAtual') ?? 1;
    });
  }

  // Carrega o animatrônico salvo nas preferências
  Future<void> _carregarAnimatronico() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString('animatronic') ?? 'freddy';
    setState(() {
      _animatronico = salvo;
    });
  }

  // Salva o animatrônico escolhido e atualiza a tela
  Future<void> _selecionarAnimatronico(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('animatronic', nome);
    setState(() {
      _animatronico = nome;
    });
  }

  Future<void> _checarVolumeInicial() async {
    double? volume = await FlutterVolumeController.getVolume();
    if (volume != null) {
      setState(() {
        _volumeNoMaximo = (volume >= 0.95);
      });
    }
  }

  void _ouvirMudancasDeVolume() {
    FlutterVolumeController.addListener((volume) {
      setState(() {
        _volumeNoMaximo = (volume >= 0.95);
      });
    });
  }

  void _mostrarAvisoVolume(VoidCallback callbackSucesso) {
    bool volumeMaximoNoDialog = _volumeNoMaximo;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            FlutterVolumeController.addListener((volume) {
              if (mounted) {
                setDialogState(() {
                  volumeMaximoNoDialog = (volume >= 0.95);
                });
                setState(() {
                  _volumeNoMaximo = (volume >= 0.95);
                });
              }
            });

            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: const Color(0xFF1A0033),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: volumeMaximoNoDialog
                        ? Colors.cyanAccent
                        : Colors.redAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(
                  volumeMaximoNoDialog
                      ? "SISTEMA PRONTO"
                      : "ALERTA DE SEGURANÇA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: volumeMaximoNoDialog
                        ? Colors.cyanAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        volumeMaximoNoDialog
                            ? "Dispositivo calibrado com sucesso. Você não tomará sustos de surpresa..."
                            : "O systema detectou que o áudio do ambiente está muito baixo.\n\nPara garantir que você ouça os animatronics no labirinto, configure o volume no MÁXIMO. \n\n Nota: Não se preocupe se estiver usando fones, o volume já foi adaptado para o seu conforto.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 4,
                        width: double.infinity,
                        color: volumeMaximoNoDialog
                            ? Colors.cyanAccent
                            : Colors.redAccent,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: volumeMaximoNoDialog
                              ? Colors.cyanAccent.withValues(alpha: 0.1)
                              : Colors.grey[900],
                          foregroundColor: volumeMaximoNoDialog
                              ? Colors.cyanAccent
                              : Colors.grey[600],
                          side: BorderSide(
                            color: volumeMaximoNoDialog
                                ? Colors.cyanAccent
                                : Colors.grey[800]!,
                            width: 1.5,
                          ),
                          fixedSize: const Size(220, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: volumeMaximoNoDialog ? 15 : 0,
                        ),
                        onPressed: () {
                          if (volumeMaximoNoDialog) {
                            FlutterVolumeController.removeListener();
                            _ouvirMudancasDeVolume();
                            Navigator.of(context).pop();
                            callbackSucesso();
                          }
                        },
                        child: Text(
                          volumeMaximoNoDialog
                              ? "ENTRAR NO LABIRINTO"
                              : "AUMENTE O VOLUME",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: volumeMaximoNoDialog
                                ? Colors.white
                                : Colors.grey[600],
                            shadows: volumeMaximoNoDialog
                                ? [
                                    Shadow(
                                      color: Colors.cyanAccent,
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: const [],
              ),
            );
          },
        );
      },
    ).then((_) {
      FlutterVolumeController.removeListener();
      _ouvirMudancasDeVolume();
    });
  }

  // DIÁLOGO DE SELEÇÃO DE ANIMATRÔNICO
  void _mostrarSelecaoAnimatronico() {
    final opcoes = ['freddy', 'bonnie', 'chica', 'foxy'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A0033),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: _corAtual, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                "Escolha seu animatronic",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _corAtual,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: opcoes.map((nome) {
                    final cor = _coresAnimatronic[nome]!;
                    final selecionado = _animatronico == nome;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selecionado
                                ? cor.withValues(alpha: 0.25)
                                : cor.withValues(alpha: 0.08),
                            foregroundColor: cor,
                            side: BorderSide(
                              color: cor,
                              width: selecionado ? 2.0 : 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: selecionado ? 10 : 2,
                          ),
                          onPressed: () async {
                            await _selecionarAnimatronico(nome);

                            if (!context.mounted) return;

                            Navigator.of(context).pop();

                            if (_animatronico == "freddy") {
                              await playerFreddy.play(
                                AssetSource('audios/freddy.ogg'),
                                volume: 0.025,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/$nome.webp',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _nomesAnimatronic[nome]!,
                                style: TextStyle(
                                  color: cor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  shadows: [Shadow(color: cor, blurRadius: 8)],
                                ),
                              ),
                              const Spacer(),
                              if (selecionado)
                                Icon(Icons.check_circle, color: cor, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: const [],
            );
          },
        );
      },
    );
  }

  Future<void> iniciarMusica() async {
    await musicaPlayer.setReleaseMode(ReleaseMode.loop);
    await musicaPlayer.play(AssetSource('audios/menu.ogg'), volume: 0.05);
  }

  void iniciarEfeitoPiscada() {
    _executarCicloPiscada();
  }

  void _executarCicloPiscada() async {
    if (!mounted) return;

    await Future.delayed(Duration(milliseconds: 5000));
    if (!mounted) return;

    setState(() => _exibirRuin = true);
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _exibirRuin = false);
    await Future.delayed(Duration(milliseconds: 200));
    if (!mounted) return;

    setState(() => _exibirRuin = true);
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _exibirRuin = false);
    await Future.delayed(Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() => _exibirRuin = true);
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _exibirRuin = false);
    await Future.delayed(Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() => _exibirRuin = true);
    await Future.delayed(Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() => _exibirRuin = false);

    _executarCicloPiscada();
  }

  Future<void> _reiniciarJogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('noiteAtual', 1);
    await prefs.setBool('viuDeeDee', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MazeScreen()),
    );
  }

  void _mostrarComoJogar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A0033),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.pinkAccent, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            "COMO JOGAR",
            style: TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 2,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _itemTutorial(
                    "• ${_nomesAnimatronic[_animatronico]} quer comer sua pizza. Leve ${_animatronico == 'chica' ? 'ela' : 'ele'} até a comida.",
                  ),
                  _itemTutorial(
                    "• Ande pelo labirinto com os botões ou com o dedo.",
                  ),
                  _itemTutorial(
                    "• Para despistar as Minireenas, chacoalhe o celular.",
                  ),
                  _itemTutorial("• Purple Guy te perseguirá durante a noite."),
                  _itemTutorial(
                    "• Portas vão surgir e bloquear o caminho, mas sumirão depois de alguns segundos.",
                  ),
                  _itemTutorial(
                    "• Se o Helpy brotar na tela, clique nele para espantá-lo.",
                  ),
                  _itemTutorial(
                    "• Quando um balão aparecer, clique nele para estourá-lo e afastar o Balloon Boy. Ele não deixará você andar caso não estoure o balão.",
                  ),
                  _itemTutorial(
                    "• ${_nomesAnimatronic[_animatronico]} não gosta de bater nas paredes.",
                  ),
                  _itemTutorial(
                    "• ${_nomesAnimatronic[_animatronico]} não gosta de ser pego pelo Purple Guy.",
                  ),
                  _itemTutorial(
                    "• ${_nomesAnimatronic[_animatronico]} não gosta de tomar jumpscare do Helpy.",
                  ),
                  _itemTutorial(
                    "• Quando ${_animatronico == 'chica' ? 'a' : 'o'} ${_nomesAnimatronic[_animatronico]} não gosta de alguma coisa, bem, ${_animatronico == 'chica' ? 'ela' : 'ele'} fica um pouquinho... irritad${_animatronico == 'chica' ? 'a' : 'o'}...",
                    destaque: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ButtonTheme(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.pinkAccent,
                  side: BorderSide(color: Colors.pinkAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    "ENTENDIDO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _itemTutorial(String texto, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        texto,
        style: TextStyle(
          color: destaque ? Colors.redAccent : Colors.white,
          fontSize: 14,
          height: 1.4,
          fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imagemFundo = _exibirRuin
        ? 'assets/images/${_animatronico}_home_ruin.webp'
        : 'assets/images/${_animatronico}_home.webp';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // FUNDO
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF12001F), Color(0xFF090011), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // IMAGEM DE FUNDO
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(imagemFundo, height: 1000, fit: BoxFit.cover),

                // Sobreposição de estática
                Center(
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      'assets/images/estatica.webp',
                      height: 1000,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Área clicável do focinho (Easter Egg)
                Positioned(
                  top: _animatronico == 'foxy' ? 340 : 325,
                  left: _animatronico == 'foxy' ? 180 : 150,
                  child: GestureDetector(
                    onTap: () async {
                      await playerFucinho.stop();
                      await playerFucinho.play(
                        AssetSource('audios/fucinho.ogg'),
                        volume: 0.025,
                      );

                      // Incrementa o contador de cliques
                      _cliquesFucinho++;

                      // Se chegar a 5 cliques, reseta e vai para o minigame
                      if (_cliquesFucinho >= 5) {
                        _cliquesFucinho = 0; // Reseta o contador

                        // Interrompe a música do menu antes de mudar de tela
                        await musicaPlayer.stop();

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MinigameScreen(),
                          ),
                        );
                      }
                    },
                    child: Opacity(
                      opacity: 0,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/fazbear_maze.webp',
                    height: 70,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 16),

                  // Botão do Animatrônico
                  GestureDetector(
                    onTap: _mostrarSelecaoAnimatronico,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0033),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _corAtual, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _corAtual.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/$_animatronico.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TEXTO E BOTÕES (parte inferior)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (noiteAtual == 7)
                  Image.asset(
                    'assets/images/${_animatronico}_67.webp',
                    height: _animatronico == 'bonnie' ? 230 : 200,
                    fit: BoxFit.contain,
                  ),
                // BOTÃO: NEW GAME
                ElevatedButton(
                  onPressed: () {
                    if (_volumeNoMaximo) {
                      _reiniciarJogo();
                    } else {
                      _mostrarAvisoVolume(() => _reiniciarJogo());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    fixedSize: const Size(220, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.redAccent,
                    elevation: 15,
                  ),
                  child: const Text(
                    "NEW GAME",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.redAccent, blurRadius: 10),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // BOTÃO: CONTINUAR
                ElevatedButton(
                  onPressed: () {
                    void irParaJogo() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MazeScreen()),
                      );
                    }

                    if (_volumeNoMaximo) {
                      irParaJogo();
                    } else {
                      _mostrarAvisoVolume(() => irParaJogo());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.purpleAccent,
                    side: const BorderSide(
                      color: Colors.purpleAccent,
                      width: 2,
                    ),
                    fixedSize: const Size(220, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.purpleAccent,
                    elevation: 15,
                  ),
                  child: const Text(
                    "CONTINUAR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.purpleAccent, blurRadius: 10),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // BOTÃO: COMO JOGAR
                ElevatedButton(
                  onPressed: _mostrarComoJogar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.cyanAccent,
                    side: BorderSide(color: Colors.cyanAccent, width: 2),
                    fixedSize: Size(220, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.cyanAccent,
                    elevation: 15,
                  ),
                  child: Text(
                    "COMO JOGAR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.cyanAccent, blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
