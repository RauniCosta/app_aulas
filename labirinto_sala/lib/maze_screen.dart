import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:vibration/vibration.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:audio_session/audio_session.dart';

class MazeScreen extends StatefulWidget {
  const MazeScreen({super.key});
  @override
  State<MazeScreen> createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> with WidgetsBindingObserver {
  late List<List<int>> mapaDoLabirinto;

  bool _avisoAberto = false;
  final ValueNotifier<bool> _volumeProntoNotifier = ValueNotifier<bool>(false);

  int posicaoPersonagemX = 1;
  int posicaoPersonagemY = 1;

  final int pontoDePartidaX = 1;
  final int pontoDePartidaY = 1;

  int noiteAtual = 1;
  int tamanhoAtualDaMatriz = 7;

  int totalPassosCaminho = 1;
  int progressoAtualCaminho = 0;

  bool jogoIniciado = false;

  final AudioPlayer musicaPlayer = AudioPlayer();
  final AudioPlayer playerJumpscare6am = AudioPlayer();
  final AudioPlayer playerPurpleGuy = AudioPlayer();
  final AudioPlayer efeitoPlayer = AudioPlayer();
  final AudioPlayer playerHelpy = AudioPlayer();
  final AudioPlayer playerMoeda3d = AudioPlayer();
  final AudioPlayer playerGritoCrianca = AudioPlayer();
  final AudioPlayer playerFreddy = AudioPlayer();
  final AudioPlayer playerFalaBalloonBoy = AudioPlayer();
  final AudioPlayer playerRisadaBalloonBoy = AudioPlayer();
  final AudioPlayer playerBtnBloqueado = AudioPlayer();
  final AudioPlayer playerBalloonEstourando = AudioPlayer();
  final AudioPlayer playerPorta = AudioPlayer();
  // NOVOS PLAYERS
  final AudioPlayer playerDeeDee = AudioPlayer();
  final AudioPlayer playerChallenger = AudioPlayer();
  final AudioPlayer playerGoldenFreddy = AudioPlayer();

  bool mostrandoJumpscare = false;
  bool mostrandoJumpscareHelpy = false;
  bool helpyClicado = false;
  bool mostrando6AM = false;
  bool mostrandoMinireena = false;
  bool mostrandoHelpy = false;
  bool mostrandoBalloon = false;
  bool mostrandoBalloonBoy = false;
  Key gifKey = UniqueKey();
  bool _gestoProcessado = false;
  Widget? filhoDoContainer;
  int tamanhoCustomNight = 7;
  bool _exibirRuin = false;
  bool _moreOpacity = false;

  // NOVOS ESTADOS: DeeDee, Challenger e Golden Freddy
  bool mostrandoDeeDee = false;
  double deeDeeOffsetY =
      0.0; // 0 = fora da tela (abaixo), 1 = posição final visível
  bool mostrandoChallenger = false;
  bool mostrandoGoldenFreddy = false;
  Timer? _timerGoldenFreddy;

  // POSIÇÃO DO PURPLE GUY
  int? purpleGuyX;
  int? purpleGuyY;
  int? ultimoPurpleGuyX;
  int? ultimoPurpleGuyY;

  // CONTROLE
  bool purpleGuyAtivo = false;
  bool purpleGuyPegou = false;

  Timer? timerMovimentoPurpleGuy;
  Timer? _timerPortas;
  StreamSubscription? _subscriptionAcelerometro;
  final double limiteChacoalhao = 0.25;

  List<Map<String, int>> posicoesPortas = [];
  bool portasAtivas = false;

  bool mostrarFuncionalidadesCN = true;
  bool modoNightmareCustomNight = false;
  bool temPortaCustomNight = false;
  bool temPurpleGuyCustomNight = false;
  bool temMinireenaCustomNight = false;
  bool temHelpyCustomNight = false;
  bool temBalloonBoyCustomNight = false;

  Timer? _helpyAparecerTimer;
  double helpyPosicaoX = 0.0;
  double helpyPosicaoY = 0.0;

  Timer? _timerMinireena;

  Timer? _balloonAparecerTimer;
  Timer? _balloonMovimentoTimer;
  double balloonPosicaoX = 0.0;
  double balloonPosicaoY = 0.0;
  double balloonWidth = 80.0;
  bool isJogadorVisivel = true;

  final Random _random = Random();

  bool _jogoPausado = false;

  bool _isHeadphoneConnected = false;
  AudioSession? _session;

  String _animatronico = 'freddy';

  // DEFINIÇÃO PRÉ-DEFINIDA DAS 6 NOITES (Tamanhos ímpares crescentes)
  static const Map<int, int> mapaNoites = {
    1: 7, // Noite 1
    2: 9, // Noite 2
    3: 11, // Noite 3
    4: 13, // Noite 4
    5: 15, // Noite 5
    6: 17, // Noite 6
  };

  // Controle do input para a Custom Night (Noite 7)
  final TextEditingController _customNightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tamanhoAtualDaMatriz = mapaNoites[noiteAtual] ?? 7;
    mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
    calcularCaminhoCorreto();
    WidgetsBinding.instance.addObserver(this);
    _gerenciarMusicaAmbiente();
    _carregarNivel();
    _preCarregarAudios();
    _initAudioSession();
    _carregarAnimatronico();

    // MOVA o listener de volume para DEPOIS do primeiro frame
    // Isso garante que o canal nativo já está registrado no release
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarListenerVolume();
    });
  }

  @override
  void dispose() {
    _volumeProntoNotifier.dispose();
    musicaPlayer.dispose();
    playerJumpscare6am.dispose();
    playerPurpleGuy.dispose();
    efeitoPlayer.dispose();
    playerHelpy.dispose();
    playerMoeda3d.dispose();
    playerGritoCrianca.dispose();
    playerFreddy.dispose();
    playerFalaBalloonBoy.dispose();
    playerRisadaBalloonBoy.dispose();
    playerBtnBloqueado.dispose();
    playerBalloonEstourando.dispose();
    playerPorta.dispose();
    playerDeeDee.dispose();
    playerChallenger.dispose();
    playerGoldenFreddy.dispose();

    timerMovimentoPurpleGuy?.cancel();
    _timerPortas?.cancel();
    _helpyAparecerTimer?.cancel();
    _balloonAparecerTimer?.cancel();
    _balloonMovimentoTimer?.cancel();
    _timerGoldenFreddy?.cancel();

    _subscriptionAcelerometro?.cancel();
    _customNightController.dispose();

    FlutterVolumeController.removeListener();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _jogoPausado = true;
      musicaPlayer.pause();
      playerRisadaBalloonBoy.pause();
      playerDeeDee.pause();

      _helpyAparecerTimer?.cancel();
      _balloonAparecerTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _jogoPausado = false;
      musicaPlayer.resume();
      if (mostrandoBalloonBoy) playerRisadaBalloonBoy.resume();

      if (mostrandoDeeDee) playerDeeDee.resume();

      if (jogoIniciado) {
        if (!mostrandoHelpy) {
          if (noiteAtual >= 4) {
            if (noiteAtual != 7 || temHelpyCustomNight) {
              _helpyAparecerTimer?.cancel(); // cancelar antes de recriar
              iniciarCicloDoHelpy();
            }
          }
        } else if (mostrandoHelpy && !helpyClicado) {
          if (noiteAtual >= 4) {
            if (noiteAtual != 7 || temHelpyCustomNight) {
              _reprogramarJumpscareHelpy();
            }
          }
        }
        if (!mostrandoBalloon) {
          if (noiteAtual >= 5) {
            if (noiteAtual != 7 || temBalloonBoyCustomNight) {
              _balloonAparecerTimer?.cancel();
              iniciarCicloDoBalloonBoy();
            }
          }
        }
        if (!mostrandoMinireena) {
          if (noiteAtual != 7 || temMinireenaCustomNight) {
            _timerMinireena?.cancel();
            _iniciarCicloMinireena();
          }
        }
      }
    }
  }

  Future<void> _carregarAnimatronico() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString('animatronic') ?? 'freddy';
    setState(() {
      _animatronico = salvo;
    });
  }

  void _iniciarListenerVolume() async {
    FlutterVolumeController.removeListener();

    // Aguarda o plugin nativo estar completamente pronto
    // Essencial no release (AOT é mais rápido que o canal nativo inicializa)
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Checa o volume atual
    double? volumeAtual = await FlutterVolumeController.getVolume();

    if (volumeAtual != null && volumeAtual < 0.95 && !_avisoAberto) {
      _pausarEExigirVolume();
      return;
    }

    // Registra o listener com verificação de montagem
    FlutterVolumeController.addListener((volume) {
      if (!mounted || _avisoAberto) return; // Guard no release
      if (volume < 0.95) {
        _pausarEExigirVolume();
      }
    });
  }

  Future<void> _initAudioSession() async {
    _session = await AudioSession.instance;
    await _session!.configure(const AudioSessionConfiguration.music());

    // 1. Verifica o estado inicial ao abrir a tela
    // getDevices() retorna um List<AudioDevice>, então convertemos para Set com .toSet()
    final currentDevices = (await _session!.getDevices()).toSet();
    _verificarEAtualizarDispositivos(currentDevices);

    // 2. Escuta as mudanças em tempo real (conectar/desconectar fone)
    // Deixamos o Dart inferir o tipo (que será Set<AudioDevice>)
    _session!.devicesStream.listen((devices) {
      _verificarEAtualizarDispositivos(devices);
    });
  }

  // Mudamos o tipo do parâmetro aqui para Set<AudioDevice>
  void _verificarEAtualizarDispositivos(Set<AudioDevice> devices) {
    bool headphoneDetected = false;

    for (var device in devices) {
      if (device.isOutput) {
        // ignore: experimental_member_use
        if (device.type == AudioDeviceType.wiredHeadphones ||
            // ignore: experimental_member_use
            device.type == AudioDeviceType.wiredHeadset || // Mantido o correto
            // ignore: experimental_member_use
            device.type == AudioDeviceType.bluetoothA2dp ||
            // ignore: experimental_member_use
            device.type == AudioDeviceType.bluetoothLe) {
          headphoneDetected = true;
          break;
        }
      }
    }

    // Se mudou o estado do fone, atualiza o estado e os volumes
    if (_isHeadphoneConnected != headphoneDetected) {
      setState(() {
        _isHeadphoneConnected = headphoneDetected;
      });

      _iniciarListenerVolume();
    }
  }

  void _pausarEExigirVolume() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _avisoAberto = true;
      });

      _jogoPausado = true;
      musicaPlayer.pause();
      playerRisadaBalloonBoy.pause();

      _helpyAparecerTimer?.cancel();
      _balloonAparecerTimer?.cancel();
      _balloonMovimentoTimer?.cancel();

      // Registra o listener FORA do dialog, no estado principal
      FlutterVolumeController.removeListener();
      FlutterVolumeController.addListener((volume) {
        if (!mounted) return;
        _volumeProntoNotifier.value = (volume >= 0.95);
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: false,
            child: ValueListenableBuilder<bool>(
              valueListenable: _volumeProntoNotifier,
              builder: (context, volumePronto, _) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF1A0033),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: volumePronto
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Text(
                    volumePronto
                        ? "VOLUME REESTABELECIDO"
                        : "ALERTA DE SEGURANÇA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: volumePronto
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          volumePronto
                              ? "Áudio do labirinto normalizado."
                              : "VOCÊ NÃO PODE SE ESCONDER NO SILÊNCIO.\n\n O volume está muito baixo. Aumente no MÁXIMO para continuar explorando o labirinto. \n\n Nota: Não se preocupe se estiver usando fones, o volume já foi adaptado para o seu conforto.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: volumePronto
                                ? Colors.greenAccent.withValues(alpha: 0.1)
                                : Colors.grey[900],
                            foregroundColor: volumePronto
                                ? Colors.greenAccent
                                : Colors.grey[600],
                            side: BorderSide(
                              color: volumePronto
                                  ? Colors.greenAccent
                                  : Colors.grey[800]!,
                              width: 1.5,
                            ),
                            fixedSize: const Size(220, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (volumePronto) {
                              Navigator.of(dialogContext).pop();
                              await Future.delayed(Duration(milliseconds: 250));
                              FlutterVolumeController.removeListener();
                              _volumeProntoNotifier.value = false;

                              setState(() {
                                _avisoAberto = false;
                              });

                              _iniciarListenerVolume();
                              _jogoPausado = false;
                              musicaPlayer.resume();
                              if (mostrandoBalloonBoy) {
                                playerRisadaBalloonBoy.resume();
                              }
                            }
                          },
                          child: Text(
                            volumePronto
                                ? "RETORNAR AO JOGO"
                                : "AUMENTE O VOLUME",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }

  Future<void> _preCarregarAudios() async {
    // Isso joga os áudios na memória antes do jogo começar
    await playerHelpy.setSource(AssetSource('audios/helpy_clicado.ogg'));
    await playerRisadaBalloonBoy.setSource(
      AssetSource('audios/balloon_boy_risada.ogg'),
    );
    await playerBalloonEstourando.setSource(
      AssetSource('audios/balloon_estourando.ogg'),
    );
  }

  int _bfsDistancia(int origemX, int origemY, int destinoX, int destinoY) {
    int tamanho = mapaDoLabirinto.length;
    List<List<int>> fila = [
      [origemX, origemY, 0],
    ];
    Set<String> visitados = {"$origemX,$origemY"};
    List<List<int>> direcoes = [
      [0, -1],
      [1, 0],
      [0, 1],
      [-1, 0],
    ];

    while (fila.isNotEmpty) {
      var atual = fila.removeAt(0);
      int x = atual[0], y = atual[1], dist = atual[2];

      if (x == destinoX && y == destinoY) return dist;

      for (var dir in direcoes) {
        int nx = x + dir[0];
        int ny = y + dir[1];
        if (ny >= 0 && ny < tamanho && nx >= 0 && nx < tamanho) {
          int cel = mapaDoLabirinto[ny][nx];
          if ((cel == 0 || cel == 2 || cel == 3) &&
              !visitados.contains("$nx,$ny")) {
            visitados.add("$nx,$ny");
            fila.add([nx, ny, dist + 1]);
          }
        }
      }
    }
    return -1; // não encontrou
  }

  void calcularCaminhoCorreto() {
    int tamanho = mapaDoLabirinto.length;
    int fimX = tamanho - 2;
    int fimY = tamanho - 2;

    int dist = _bfsDistancia(1, 1, fimX, fimY);
    setState(() {
      totalPassosCaminho = dist > 0 ? dist : 1;
      progressoAtualCaminho = 0;
    });
  }

  String obterHorarioFnaf() {
    // Evita divisão por zero se o mapa não foi calculado
    if (totalPassosCaminho == 0) return "12 AM";

    // Calcula a porcentagem baseado nos passos dados vs passos totais
    double progresso = progressoAtualCaminho / totalPassosCaminho;
    progresso = progresso.clamp(0.0, 1.0);

    int hora = (progresso * 6).floor();

    if (hora == 0) {
      return "12 AM";
    } else {
      return "$hora AM";
    }
  }

  void iniciarCicloDoHelpy() {
    if (noiteAtual <= 3) return;

    // Cancela timers anteriores para evitar duplicações indesejadas
    _helpyAparecerTimer?.cancel();

    // Dispara o timer de 5 segundos para fazer o Helpy aparecer

    final temposPorNivel = [
      Duration(milliseconds: 4000), // Nível 3
      Duration(milliseconds: 3500), // Nível 4
      Duration(milliseconds: 3000), // Nível 5
      Duration(milliseconds: 2500), // Nível 6
      Duration(milliseconds: 2000), // Nível 7
    ];

    _helpyAparecerTimer = Timer(temposPorNivel[noiteAtual - 3], () async {
      if (_jogoPausado) return;
      if (!mounted || !jogoIniciado) {
        return; // Só aparece se o jogo estiver rodando
      }

      setState(() {
        mostrandoHelpy = true;
        // Gera posições aleatórias em porcentagem (de 0.0 a 0.8 para não cortar nas bordas)
        helpyPosicaoX = _random.nextDouble() * 0.8;
        helpyPosicaoY = _random.nextDouble() * 0.8;
      });

      final temposPorNivelJumpscare = [
        Duration(milliseconds: 3000), // Nível 4
        Duration(milliseconds: 2500), // Nível 5
        Duration(milliseconds: 2000), // Nível 6
        Duration(milliseconds: 1500), // Nível 7
      ];
      await Future.delayed(temposPorNivelJumpscare[noiteAtual - 4]);
      if (_jogoPausado) return;
      if (mostrandoHelpy && jogoIniciado && !helpyClicado) {
        mostrarJumpscareHelpy();
      }
    });
  }

  void clicarNoHelpy() async {
    // Cancela o timer do jumpscare já que o jogador foi rápido o suficiente
    setState(() {
      helpyClicado = true;
    });

    await playerHelpy.play(
      AssetSource('audios/helpy_clicado.ogg'),
      volume: 0.025,
    );

    await Future.delayed(Duration(milliseconds: 250));

    setState(() {
      mostrandoHelpy = false;
      helpyClicado = false;
    });

    // Reinicia o ciclo (espera mais 5 segundos para reaparecer)
    iniciarCicloDoHelpy();
  }

  void mostrarJumpscareHelpy() async {
    if (mostrandoJumpscareHelpy) return;
    if (mostrandoJumpscare) return;

    timerMovimentoPurpleGuy?.cancel();
    _timerPortas?.cancel();
    _helpyAparecerTimer?.cancel();
    _balloonAparecerTimer?.cancel();
    _balloonMovimentoTimer?.cancel();
    _timerGoldenFreddy?.cancel();

    final imageProvider = AssetImage('assets/images/helpy_jumpscare.webp');
    final key = await imageProvider.obtainKey(ImageConfiguration.empty);
    PaintingBinding.instance.imageCache.evict(key);

    setState(() {
      mostrandoJumpscareHelpy = true;
      gifKey = UniqueKey();
      mostrandoHelpy = false;
    });

    _helpyAparecerTimer?.cancel();

    await musicaPlayer.pause();
    await playerJumpscare6am.stop();
    await playerJumpscare6am.play(
      AssetSource('audios/helpy_jumpscare.ogg'),
      volume: _isHeadphoneConnected ? 0.015 : 1.0,
    );

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 10000]);
    }

    await Future.delayed(Duration(seconds: 2));
    await playerJumpscare6am.pause();
    Vibration.cancel();

    mostrarJumpscare();

    await Future.delayed(Duration(milliseconds: 16));
    if (mounted) {
      setState(() {
        mostrandoJumpscareHelpy = false;
      });
    }
  }

  void _reprogramarJumpscareHelpy() async {
    await Future.delayed(Duration(milliseconds: 1200));

    if (_jogoPausado) {
      return; // Segurança caso ele minimize de novo instantaneamente
    }

    if (mostrandoHelpy && jogoIniciado && !helpyClicado) {
      mostrarJumpscareHelpy();
    }
  }

  void iniciarCicloDoBalloonBoy() {
    if (noiteAtual <= 4) return;

    // Cancela timers anteriores para evitar duplicações indesejadas
    _balloonAparecerTimer?.cancel();
    _balloonMovimentoTimer?.cancel();

    final temposPorNivel = [
      Duration(milliseconds: 4000), // Nível 4
      Duration(milliseconds: 3500), // Nível 5
      Duration(milliseconds: 3000), // Nível 6
      Duration(milliseconds: 2500), // Nível 7
    ];

    _balloonAparecerTimer = Timer(temposPorNivel[noiteAtual - 4], () async {
      if (_jogoPausado) return;
      if (!mounted || !jogoIniciado) {
        return; // Só aparece se o jogo estiver rodando
      }

      setState(() {
        mostrandoBalloon = true;

        final larguraTela = MediaQuery.of(context).size.width;

        // 1. Margem baseada no tamanho INICIAL (40px de margem em vez de 100px)
        double margemNascimento = (balloonWidth / 2) / larguraTela;

        double limiteMinimoX = margemNascimento;
        double limiteMaximoX = 1.0 - margemNascimento;

        // 2. Sorteia aproveitando quase toda a largura da tela
        balloonPosicaoX =
            limiteMinimoX +
            (_random.nextDouble() * (limiteMaximoX - limiteMinimoX));

        balloonPosicaoY = 1.05;
      });
      _iniciarSubidaDoBalao();
      final listaAudios = [
        'audios/balloon_boy_hi.ogg',
        'audios/balloon_boy_hello.ogg',
        'audios/balloon_boy_risada.ogg',
      ];
      final audioSorteado = listaAudios[_random.nextInt(listaAudios.length)];
      await playerFalaBalloonBoy.play(
        AssetSource(audioSorteado),
        volume: 0.025,
      );
    });
  }

  void _iniciarSubidaDoBalao() {
    _balloonMovimentoTimer = Timer.periodic(Duration(milliseconds: 16), (
      timer,
    ) async {
      if (_jogoPausado) return;
      if (!mounted || !mostrandoBalloon || !jogoIniciado) {
        timer.cancel();
        return;
      }

      setState(() {
        balloonPosicaoY -= 0.005;
      });

      // 4. Sumir ao passar do topo
      if (balloonPosicaoY < -0.05) {
        _balloonMovimentoTimer?.cancel();
        setState(() {
          mostrandoBalloonBoy = true;
        });
        iniciarRisada();

        final temposPorNivel = [
          Duration(milliseconds: 2000), // Nível 5
          Duration(milliseconds: 3000), // Nível 6
          Duration(milliseconds: 3500), // Nível 7
        ];

        await Future.delayed(temposPorNivel[noiteAtual - 5]);
        if (_jogoPausado) return;
        mostrandoBalloonBoy = false;
        iniciarCicloDoBalloonBoy();
        await playerRisadaBalloonBoy.stop();
      }
    });
  }

  Future<void> iniciarRisada() async {
    await playerRisadaBalloonBoy.setReleaseMode(ReleaseMode.loop);
    await playerRisadaBalloonBoy.play(
      AssetSource('audios/balloon_boy_risada.ogg'),
      volume: 0.025,
    );
  }

  Future<void> balloonEstourando() async {
    await playerBalloonEstourando.play(
      AssetSource('audios/balloon_estourando.ogg'),
      volume: 0.025,
    );
  }

  void _tocarSomCascata(String caminho) async {
    await efeitoPlayer
        .stop(); // Para o som anterior se a Minireena aparecer de novo
    await efeitoPlayer.play(AssetSource(caminho), volume: 0.05);
  }

  Future<void> verificarChacoalhao() async {
    await gyroscopeEventStream().first.timeout(const Duration(seconds: 1));
    await userAccelerometerEventStream().first.timeout(
      const Duration(seconds: 1),
    );
    if (noiteAtual == 7 && !temMinireenaCustomNight) return;
    _iniciarCicloMinireena();
    _ouvirOChacoalhao();
  }

  void _iniciarCicloMinireena() {
    _timerMinireena?.cancel();

    if (!mounted || !jogoIniciado) return;
    if (noiteAtual == 7 && !temMinireenaCustomNight) return;

    final temposPorNivel = [
      Duration(milliseconds: 1000), // Nível 1
      Duration(milliseconds: 1250), // Nível 2
      Duration(milliseconds: 1500), // Nível 3
      Duration(milliseconds: 1750), // Nível 4
      Duration(milliseconds: 2000), // Nível 5
      Duration(milliseconds: 2250), // Nível 6
      Duration(milliseconds: 2500), // Nível 7
    ];

    _timerMinireena = Timer(temposPorNivel[noiteAtual - 1], () {
      if (!mounted || !jogoIniciado || _jogoPausado) return;
      if (noiteAtual == 7 && !temMinireenaCustomNight) return;

      if (!mostrandoMinireena) {
        setState(() {
          mostrandoMinireena = true;
        });
        final listaAudios = [
          'audios/minireena1.ogg',
          'audios/minireena2.ogg',
          'audios/minireena3.ogg',
        ];
        final audioSorteado = listaAudios[_random.nextInt(listaAudios.length)];
        _tocarSomCascata(audioSorteado);
      }
    });
  }

  void _ouvirOChacoalhao() {
    _subscriptionAcelerometro = userAccelerometerEventStream().listen((
      UserAccelerometerEvent event,
    ) {
      // Se ela não está na tela, não precisamos calcular nada
      if (!mostrandoMinireena) return;

      // Calculando a força resultante nos 3 eixos (X, Y, Z)
      double forcaResultante =
          event.x * event.x + event.y * event.y + event.z * event.z;
      double magnitude = forcaResultante / 10;
      // Nota: O valor padrão parado na Terra é em torno de 9.8 (gravidade).
      // Um chacoalhão forte passa facilmente de 25~30.

      if (magnitude > limiteChacoalhao) {
        setState(() {
          mostrandoMinireena = false;
        });
        _iniciarCicloMinireena();
      }
    });
  }

  // Salva o nível atual no SharedPreferences
  Future<void> _salvarNivel(int nivel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('noiteAtual', nivel);
  }

  // Carrega o nível salvo e regenera o labirinto com o tamanho correto
  Future<void> _carregarNivel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Se não houver nada salvo, o padrão será 1
      noiteAtual = prefs.getInt('noiteAtual') ?? 1;
      
      // Atualiza o tamanho da matriz com base no nível recuperado
      tamanhoAtualDaMatriz = mapaNoites[noiteAtual] ?? 7;
      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
      calcularCaminhoCorreto();
    });
    if (noiteAtual == 6) {
      setState(() {
        _exibirRuin = true;
        iniciarEfeitoPiscada();
        _gerenciarMusicaAmbiente();
      });
    }
  }

  Future<void> _gerenciarMusicaAmbiente() async {
    await musicaPlayer.stop();
    await musicaPlayer.setReleaseMode(ReleaseMode.loop);
    await musicaPlayer.play(
      AssetSource(
        _exibirRuin ? 'audios/ambiente_ruin.ogg' : 'audios/ambiente.ogg',
      ),
      volume: _isHeadphoneConnected ? 0.025 : 0.05,
    );
  }

  void iniciarEfeitoPiscada() {
    if (_exibirRuin) {
      _executarCicloPiscada();
    }
  }

  void _executarCicloPiscada() async {
    if (!mounted) return;

    await Future.delayed(Duration(milliseconds: 5000));
    if (!mounted) return;

    setState(() => _moreOpacity = true);
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _moreOpacity = false);
    await Future.delayed(Duration(milliseconds: 200));
    if (!mounted) return;

    setState(() => _moreOpacity = true);
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _moreOpacity = false);
    await Future.delayed(Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() => _moreOpacity = true);
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _moreOpacity = false);
    await Future.delayed(Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() => _moreOpacity = true);
    await Future.delayed(Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() => _moreOpacity = false);

    _executarCicloPiscada();
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

  void iniciarJogo() async {
    // --- LÓGICA DA DEE DEE (Noite 7, primeira vez) ---
    if (noiteAtual == 7) {
      final prefs = await SharedPreferences.getInstance();
      final viuDeeDee = prefs.getBool('viuDeeDee') ?? false;

      if (!viuDeeDee) {
        await _executarIntroDeeDee();
        await prefs.setBool('viuDeeDee', true);
      }
    }

    setState(() {
      jogoIniciado = true;
    });

    verificarChacoalhao();
    if (noiteAtual >= 3) {
      if (noiteAtual != 7 || temPortaCustomNight) {
        iniciarCicloPortas();
      }
    }
    if (noiteAtual >= 4) {
      if (noiteAtual != 7 || temHelpyCustomNight) {
        iniciarCicloDoHelpy();
      }
    }
    if (noiteAtual >= 5) {
      if (noiteAtual != 7 || temBalloonBoyCustomNight) {
        iniciarCicloDoBalloonBoy();
      }
    }

    // --- GOLDEN FREDDY (Noite 7) ---
    if (noiteAtual == 7) {
      Future.delayed(Duration(seconds: 10), () {
        if (mounted && jogoIniciado && !_jogoPausado) {
          iniciarCicloGoldenFreddy();
        }
      });
    }
  }

  /// Executa a animação de entrada/saída da Dee Dee e o Challenger.
  Future<void> _executarIntroDeeDee() async {
    if (!mounted) return;

    // Pausa a música durante a cena
    await musicaPlayer.pause();

    // --- 1. Dee Dee sobe (2 segundos) ---
    setState(() {
      mostrandoDeeDee = true;
      deeDeeOffsetY = 1.0; // começa abaixo da tela (offset = altura da imagem)
    });

    await playerDeeDee.play(AssetSource('audios/dee_dee.ogg'), volume: 0.05);

    // Animação de subida: incrementa o offset de 1.0 até 0.0 em ~2 segundos
    // Usamos um Timer.periodic com passos pequenos
    const int passosSubida = 80;
    const int duracaoPassoMs = 25; // 80 * 25ms = 2000ms
    for (int i = 0; i <= passosSubida; i++) {
      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: duracaoPassoMs));
      if (!mounted) return;
      setState(() {
        deeDeeOffsetY = 1.0 - (i / passosSubida);
      });
    }

    await playerDeeDee.onPlayerComplete.first;
    if (!mounted) return;

    // --- 3. Dee Dee desce (2 segundos) enquanto Challenger aparece ---
    setState(() {
      mostrandoChallenger = true;
    });
    await playerChallenger.play(
      AssetSource('audios/challenger.ogg'),
      volume: 0.05,
    );

    const int passosDescida = 80;
    for (int i = 0; i <= passosDescida; i++) {
      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: duracaoPassoMs));
      if (!mounted) return;
      setState(() {
        deeDeeOffsetY = i / passosDescida;
      });
    }

    // Dee Dee sumiu completamente
    setState(() {
      mostrandoDeeDee = false;
      deeDeeOffsetY = 1.0;
    });

    // --- 4. Challenger fica 3 segundos e some ---
    await Future.delayed(Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      mostrandoChallenger = false;
    });

    await playerDeeDee.stop();
    await playerChallenger.stop();

    // Retoma a música
    await musicaPlayer.resume();
  }

  void iniciarCicloGoldenFreddy() {
    _timerGoldenFreddy?.cancel();
    _executarAparicaoGoldenFreddy();
  }

  Future<void> _executarAparicaoGoldenFreddy() async {
    if (!mounted || !jogoIniciado || _jogoPausado) return;
    if (mostrandoJumpscare || mostrandoJumpscareHelpy) return;

    // Golden Freddy aparece
    setState(() {
      mostrandoGoldenFreddy = true;
      _jogoPausado = true;
    });

    await playerGoldenFreddy.stop();
    await playerGoldenFreddy.play(
      AssetSource('audios/golden_freddy_jumpscare.ogg'),
      volume: _isHeadphoneConnected ? 0.015 : 1.0,
    );

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 10000]);
    }

    // Fica visível por 3 segundos
    await Future.delayed(Duration(milliseconds: 1500));
    Vibration.cancel();
    if (!mounted) return;

    // Golden Freddy some
    await playerGoldenFreddy.stop();
    setState(() {
      mostrandoGoldenFreddy = false;
      _jogoPausado = false;
    });

    if (jogoIniciado) {
      if (!mostrandoHelpy && (noiteAtual != 7 || temHelpyCustomNight)) {
        _helpyAparecerTimer?.cancel();
        iniciarCicloDoHelpy();
      }

      if (!mostrandoBalloon &&
          !mostrandoBalloonBoy &&
          (noiteAtual != 7 || temBalloonBoyCustomNight)) {
        _balloonAparecerTimer?.cancel();
        _balloonMovimentoTimer?.cancel();
        iniciarCicloDoBalloonBoy();
      }

      if (!mostrandoMinireena && (noiteAtual != 7 || temMinireenaCustomNight)) {
        _timerMinireena?.cancel(); // após implementar o fix do item 6
        _iniciarCicloMinireena();
      }
    }
    // Sorteia um número entre 8 e 15
    int segundosAleatorios = 8 + _random.nextInt(15 - 8 + 1);
    _timerGoldenFreddy = Timer(Duration(seconds: segundosAleatorios), () {
      if (mounted && jogoIniciado && !_jogoPausado) {
        _executarAparicaoGoldenFreddy();
      }
    });
  }

  void iniciarCicloPortas() {
    _timerPortas?.cancel();

    final temposPorNivel = [
      Duration(milliseconds: 3500), // Nível 3
      Duration(milliseconds: 2500), // Nível 4
      Duration(milliseconds: 2000), // Nível 5
      Duration(milliseconds: 1500), // Nível 6
      Duration(milliseconds: 1000), // Nível 7
    ];

    // No seu timer:
    _timerPortas = Timer.periodic(temposPorNivel[noiteAtual - 3], (timer) {
      if (_jogoPausado) return;
      if (jogoIniciado) {
        sortearPortasTemporarias();
      } else {
        // Se o jogo acabou por algum motivo externo, desliga o timer
        timer.cancel();
      }
    });
  }

  void iniciarPurpleGuy() async {
    // Só começa na noite 2
    if (noiteAtual < 2) return;

    if (!mounted || !jogoIniciado) return;

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      // Nasce exatamente no ponto inicial do jogador
      purpleGuyX = pontoDePartidaX;
      purpleGuyY = pontoDePartidaY;
      purpleGuyAtivo = true;
    });

    await playerPurpleGuy.play(
      AssetSource('audios/i_always_come_back.ogg'),
      volume: 0.025,
    );
    iniciarMovimentoPurpleGuy();
  }

  void iniciarMovimentoPurpleGuy() {
    timerMovimentoPurpleGuy?.cancel();

    final temposPorNivel = [
      Duration(milliseconds: 300), // Nível 2
      Duration(milliseconds: 400), // Nível 3
      Duration(milliseconds: 600), // Nível 4
      Duration(milliseconds: 700), // Nível 5
      Duration(milliseconds: 800), // Nível 6
      Duration(milliseconds: 900), // Nível 7
    ];

    timerMovimentoPurpleGuy = Timer.periodic(temposPorNivel[noiteAtual - 2], (
      _,
    ) {
      if (_jogoPausado) return;
      moverPurpleGuy();
    });
  }

  void moverPurpleGuy() async {
    if (!purpleGuyAtivo || !jogoIniciado) return;
    if (purpleGuyX == null || purpleGuyY == null) return;

    List<List<bool>> visitado = List.generate(
      mapaDoLabirinto.length,
      (_) => List.filled(mapaDoLabirinto[0].length, false),
    );

    List<Map<String, dynamic>> fila = [];

    fila.add({"x": purpleGuyX, "y": purpleGuyY, "caminho": []});

    visitado[purpleGuyY!][purpleGuyX!] = true;

    List<Map<String, int>> direcoes = [
      {"x": 1, "y": 0},
      {"x": -1, "y": 0},
      {"x": 0, "y": 1},
      {"x": 0, "y": -1},
    ];

    while (fila.isNotEmpty) {
      var atual = fila.removeAt(0);

      int x = atual["x"];
      int y = atual["y"];

      List<Map<String, int>> caminho = List<Map<String, int>>.from(
        atual["caminho"],
      );

      // Encontrou o jogador
      if (x == posicaoPersonagemX && y == posicaoPersonagemY) {
        if (caminho.isNotEmpty) {
          setState(() {
            purpleGuyX = caminho[0]["x"];
            purpleGuyY = caminho[0]["y"];
          });
        }

        // Captura
        if (purpleGuyX == posicaoPersonagemX &&
            purpleGuyY == posicaoPersonagemY) {
          timerMovimentoPurpleGuy?.cancel();
          _timerGoldenFreddy?.cancel();
          setState(() {
            isJogadorVisivel = false;
            jogoIniciado = false;
            purpleGuyPegou = true;
          });
          await playerPurpleGuy.play(
            AssetSource('audios/purple_guy_jumpscare.ogg'),
            volume: _isHeadphoneConnected ? 0.05 : 1.0,
          );
          await Future.delayed(Duration(milliseconds: 3500));
          mostrarJumpscare();
          purpleGuyPegou = false;
        }

        return;
      }

      for (var dir in direcoes) {
        int novoX = x + dir["x"]!;
        int novoY = y + dir["y"]!;

        // Limites
        if (novoY < 0 ||
            novoY >= mapaDoLabirinto.length ||
            novoX < 0 ||
            novoX >= mapaDoLabirinto[0].length) {
          continue;
        }

        // Parede
        if (mapaDoLabirinto[novoY][novoX] == 1) {
          continue;
        }

        // Já visitado
        if (visitado[novoY][novoX]) {
          continue;
        }

        visitado[novoY][novoX] = true;

        List<Map<String, int>> novoCaminho = List.from(caminho);

        novoCaminho.add({"x": novoX, "y": novoY});

        fila.add({"x": novoX, "y": novoY, "caminho": novoCaminho});
      }
    }
  }

  void sortearPortasTemporarias() async {
    if (!jogoIniciado || portasAtivas) return;

    await playerPorta.play(AssetSource('audios/porta.ogg'), volume: 0.025);

    setState(() {
      portasAtivas = true;
      posicoesPortas.clear();
    });

    List<Map<String, int>> celulasVazias = [];

    // i representa o Y (linhas) e j representa o X (colunas)
    for (int i = 0; i < tamanhoAtualDaMatriz; i++) {
      for (int j = 0; j < tamanhoAtualDaMatriz; j++) {
        // Corrigido usando a sua variável 'labirinto'
        if (mapaDoLabirinto[i][j] != 0) {
          continue; // Se for parede (1) ou pizza (3), pula
        }

        // Verifica as ocupações usando as coordenadas corretas (j para X, i para Y)
        bool ocupadoPeloJogador =
            (j == posicaoPersonagemX && i == posicaoPersonagemY);
        bool ocupadoPeloPurple =
            (purpleGuyAtivo && j == purpleGuyX && i == purpleGuyY);

        if (!ocupadoPeloJogador && !ocupadoPeloPurple) {
          // X recebe 'j' (coluna) e Y recebe 'i' (linha)
          celulasVazias.add({"x": j, "y": i});
        }
      }
    }

    final random = Random();
    int quantidadeDePortas = (0.045 * pow(tamanhoAtualDaMatriz, 2.1)).round();

    celulasVazias.shuffle(random);

    setState(() {
      posicoesPortas = celulasVazias.take(quantidadeDePortas).toList();
    });

    // Timer de 2 segundos para sumir com as portas
    final temposPorNivel = [
      Duration(milliseconds: 1000), // Nível 1
      Duration(milliseconds: 1250), // Nível 2
      Duration(milliseconds: 1500), // Nível 3
      Duration(milliseconds: 1750), // Nível 4
      Duration(milliseconds: 2000), // Nível 5
      Duration(milliseconds: 2500), // Nível 6
      Duration(milliseconds: 3000), // Nível 7
    ];

    // No seu timer:
    await Future.delayed(temposPorNivel[noiteAtual - 1]);

    await playerPorta.play(AssetSource('audios/porta.ogg'), volume: 0.025);
    setState(() {
      posicoesPortas.clear();
      portasAtivas = false;
    });
  }

  void reiniciarJogo() {
    calcularCaminhoCorreto();
    _timerPortas?.cancel();
    _subscriptionAcelerometro?.cancel();
    timerMovimentoPurpleGuy?.cancel();
    _timerGoldenFreddy?.cancel();
    _balloonMovimentoTimer?.cancel();
    _balloonAparecerTimer?.cancel();
    posicoesPortas.clear();
    _helpyAparecerTimer?.cancel();
    _timerMinireena?.cancel();
    setState(() {
      tamanhoCustomNight = tamanhoAtualDaMatriz;
      posicaoPersonagemX = pontoDePartidaX;
      posicaoPersonagemY = pontoDePartidaY;
      jogoIniciado = false;
      purpleGuyAtivo = false;
      purpleGuyX = null;
      purpleGuyY = null;
      ultimoPurpleGuyX = null;
      ultimoPurpleGuyY = null;
      portasAtivas = false;
      mostrandoMinireena = false;
      isJogadorVisivel = true;
      mostrandoHelpy = false;
      mostrandoBalloon = false;
      mostrandoBalloonBoy = false;
      mostrandoGoldenFreddy = false;
      _jogoPausado = false;
    });
  }

  void venceuJogo() async {
    tamanhoCustomNight = tamanhoAtualDaMatriz;
    mostrarFuncionalidadesCN = false;
    jogoIniciado = false;
    _timerGoldenFreddy?.cancel();

    await mostrar6AM();
    avancarFase();
    if (_animatronico == "freddy") {
      await playerFreddy.play(AssetSource('audios/freddy.ogg'), volume: 0.025);
    }
    await musicaPlayer.resume();
  }

  Future<void> mostrar6AM() async {
    final imageProvider = AssetImage('assets/images/6am.webp');
    final key = await imageProvider.obtainKey(ImageConfiguration.empty);
    PaintingBinding.instance.imageCache.evict(key);

    await playerMoeda3d.play(AssetSource('audios/moeda_3d.ogg'), volume: 0.025);
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      mostrando6AM = true;
      gifKey = UniqueKey();
    });

    await musicaPlayer.pause();
    await playerJumpscare6am.stop();

    await playerJumpscare6am.play(AssetSource('audios/6am.ogg'), volume: 0.025);

    await Future.delayed(Duration(milliseconds: 3500));
    await playerGritoCrianca.play(
      AssetSource('audios/grito_crianca.ogg'),
      volume: 0.025,
    );

    await Future.delayed(Duration(seconds: 5));
    await playerJumpscare6am.pause();

    if (mounted) {
      setState(() {
        mostrando6AM = false;
      });
    }
  }

  void avancarFase() {
    // 1. Cancelamento de Timers (mantido)
    timerMovimentoPurpleGuy?.cancel();
    _subscriptionAcelerometro?.cancel();
    _balloonMovimentoTimer?.cancel();
    _helpyAparecerTimer?.cancel();
    _balloonAparecerTimer?.cancel();
    _timerPortas?.cancel();
    _timerGoldenFreddy?.cancel();

    // --- LOGICA DE TRANSIÇÃO ---

    // Criamos uma flag para saber se a transição está ocorrendo AGORA
    bool acabouDeChegarNaSete = (noiteAtual == 6);

    int novaNoite = noiteAtual;
    int novoTamanhoMatriz = tamanhoAtualDaMatriz;
    bool novoExibirRuin = _exibirRuin;

    if (acabouDeChegarNaSete) {
      novaNoite = 7;
      novoTamanhoMatriz = 7;
      novoExibirRuin = false;
    } else if (noiteAtual < 6) {
      novaNoite++;
      novoTamanhoMatriz = mapaNoites[novaNoite]!;
      if (novaNoite == 6) novoExibirRuin = true;
    }
    // Se noiteAtual já for 7, ele ignora os blocos acima e mantém novaNoite = 7

    // 3. Atualização de Estado Única
    setState(() {
      noiteAtual = novaNoite;
      tamanhoAtualDaMatriz = novoTamanhoMatriz;
      _exibirRuin = novoExibirRuin;

      // Resets (mantidos)
      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
      posicaoPersonagemX = 1;
      posicaoPersonagemY = 1;
      purpleGuyAtivo = false;
      purpleGuyX = null;
      purpleGuyY = null;
      ultimoPurpleGuyX = null;
      ultimoPurpleGuyY = null;
      mostrandoMinireena = false;
      isJogadorVisivel = true;
      mostrandoHelpy = false;
      mostrandoBalloon = false;
      mostrandoBalloonBoy = false;
      mostrandoGoldenFreddy = false;
    });

    // 4. Disparos de eventos baseados na transição
    if (acabouDeChegarNaSete) {
      _mostrarAlerta67(); // Só dispara se veio da 6
    }

    if (noiteAtual == 6) {
      iniciarEfeitoPiscada();
    }

    if (noiteAtual == 7) {
      mostrarFuncionalidadesCN = true;
    }

    _gerenciarMusicaAmbiente();
    calcularCaminhoCorreto();
    _salvarNivel(noiteAtual);
  }

  void _mostrarAlerta67() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0033),
          // Centraliza os botões da lista de actions
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.pinkAccent, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            "PARABÉNS POR PASSAR A NOITE 6!!!",
            textAlign: TextAlign.center, // Centraliza o texto do título
            style: TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Fonte diminuída de 22 para 18
              letterSpacing: 2,
            ),
          ),
          content: const Text(
            "Agora, a noite 7 (Custom Night) foi desbloqueada. Mas antes, por já ter chegado até aqui, por que não dá uma olhada no easter egg que apareceu na tela inicial?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent.withValues(alpha: 0.1),
                foregroundColor: Colors.pinkAccent,
                side: const BorderSide(color: Colors.pinkAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "VOU CONFERIR!",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        );
      },
    );
  }

  // Aplica a customização da Noite 7 digitada pelo usuário
  void aplicarCustomNight() {
    setState(() {
      tamanhoAtualDaMatriz = tamanhoCustomNight;
      mapaDoLabirinto = gerarLabirinto(tamanhoAtualDaMatriz);
      calcularCaminhoCorreto();
      posicaoPersonagemX = 1;
      posicaoPersonagemY = 1;
    });
  }

  void mostrarAvisoAplicar() {
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
            "ALTERAÇÃO NÃO APLICADA",
            style: TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Você alterou o tamanho para $tamanhoCustomNight, mas não aplicou. Deseja aplicar e iniciar o labirinto novo ou jogar no tamanho atual (${tamanhoAtualDaMatriz}x$tamanhoAtualDaMatriz)?",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          actions: [
            // Botão para cancelar e manter o antigo
            TextButton(
              child: Text(
                "MANTER ATUAL",
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (!purpleGuyPegou && !mostrandoDeeDee) {
                  iniciarJogo();
                }
              },
            ),
            // Botão para aplicar a mudança automaticamente e iniciar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
              ),
              child: Text(
                "APLICAR E INICIAR",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (!purpleGuyPegou && !mostrandoDeeDee) {
                  aplicarCustomNight(); // Aplica o novo tamanho
                  iniciarJogo();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void moverPersonagem(int movimentoX, int movimentoY) {
    int proximoX = posicaoPersonagemX + movimentoX;
    int proximoY = posicaoPersonagemY + movimentoY;

    bool temPortaGeraBloqueio = posicoesPortas.any(
      (p) => p['x'] == proximoX && p['y'] == proximoY,
    );

    if (temPortaGeraBloqueio) {
      // Porta detectada! Cancela o movimento (pode tocar um som de trancado aqui)
      return;
    }

    if (proximoY >= 0 &&
        proximoY < mapaDoLabirinto.length &&
        proximoX >= 0 &&
        proximoX < mapaDoLabirinto[0].length) {
      if (mapaDoLabirinto[proximoY][proximoX] != 1) {
        int passosAteAqui = buscarDistanciaDoInicio(proximoX, proximoY);

        setState(() {
          posicaoPersonagemX = proximoX;
          posicaoPersonagemY = proximoY;

          if (passosAteAqui > progressoAtualCaminho) {
            progressoAtualCaminho = passosAteAqui;
          }
        });

        if (noiteAtual >= 2 && !purpleGuyAtivo) {
          if (noiteAtual != 7 || temPurpleGuyCustomNight) {
            iniciarPurpleGuy();
          }
        }

        if (mapaDoLabirinto[proximoY][proximoX] == 3) {
          venceuJogo();
        }
      } else {
        mostrarJumpscare();
      }
    }
  }

  int buscarDistanciaDoInicio(int alvoX, int alvoY) {
    if (alvoX == 1 && alvoY == 1) return 0;
    int dist = _bfsDistancia(1, 1, alvoX, alvoY);
    return dist >= 0 ? dist : progressoAtualCaminho;
  }

  void moverPorGesto(DragUpdateDetails detalhes) {
    if (!jogoIniciado || _gestoProcessado) return;

    // Sensibilidade: o dedo precisa mover pelo menos 8 pixels para registrar o passo
    final double sensibilidade = 8.0;
    double dx = detalhes.delta.dx;
    double dy = detalhes.delta.dy;

    int movimentoX = 0;
    int movimentoY = 0;

    if (dx.abs() > dy.abs()) {
      // Movimento Horizontal
      if (dx.abs() > sensibilidade) {
        movimentoX = dx > 0 ? 1 : -1;
        _gestoProcessado = true; // Trava o gesto
      }
    } else {
      // Movimento Vertical
      if (dy.abs() > sensibilidade) {
        movimentoY = dy > 0 ? 1 : -1;
        _gestoProcessado = true; // Trava o gesto
      }
    }

    if (movimentoX != 0 || movimentoY != 0) {
      moverPersonagem(movimentoX, movimentoY);
    }
  }

  void mostrarJumpscare() async {
    if (mostrandoJumpscare) return;

    timerMovimentoPurpleGuy?.cancel();
    _timerPortas?.cancel();
    _helpyAparecerTimer?.cancel();
    _balloonAparecerTimer?.cancel();
    _balloonMovimentoTimer?.cancel();
    _timerGoldenFreddy?.cancel();

    _subscriptionAcelerometro?.cancel();

    final imageProvider = AssetImage(
      'assets/images/${_animatronico}_jumpscare.webp',
    );
    final key = await imageProvider.obtainKey(ImageConfiguration.empty);
    PaintingBinding.instance.imageCache.evict(key);

    setState(() {
      jogoIniciado = false;
      mostrandoJumpscare = true;
      mostrandoGoldenFreddy = false;
      gifKey = UniqueKey();
    });

    await musicaPlayer.pause();
    await playerJumpscare6am.stop();
    await playerJumpscare6am.play(
      AssetSource('audios/jumpscare.ogg'),
      volume: _isHeadphoneConnected ? 0.015 : 1.0,
    );

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 10000]);
    }

    await Future.delayed(Duration(seconds: 1));
    await playerJumpscare6am.pause();
    Vibration.cancel();

    if (mounted) {
      setState(() {
        mostrandoJumpscare = false;
      });
      reiniciarJogo();
      await musicaPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDeLinhas = mapaDoLabirinto.length;
    int totalDeColunas = mapaDoLabirinto[0].length;

    // Tamanho da imagem da Dee Dee (usamos a largura da tela como referência)
    final double larguraTela = MediaQuery.of(context).size.width;
    // Altura estimada da imagem dee_dee na tela (ajuste se necessário)
    final double alturaDeeDee = larguraTela * 0.5;

    return Scaffold(
      backgroundColor: Color(0xFF090011),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF12001F), Color(0xFF090011), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // CABEÇALHO (Mais compacto)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Botão de Voltar para a Tela Inicial
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              // Cancela o cronômetro e para as músicas antes de sair
                              musicaPlayer.stop();
                              playerJumpscare6am.stop();

                              // Retorna para a tela anterior (Tela Inicial)
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        // Logo Centralizada
                        Image.asset(
                          'assets/images/fazbear_maze.webp',
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),

                  // CAMPO EXTRA PARA A NOITE 7 (Atualizado com botões + e -)
                  IgnorePointer(
                    ignoring:
                        jogoIniciado, // Bloqueia cliques se o jogo começou
                    child: Opacity(
                      opacity:
                          (noiteAtual == 7 &&
                              !jogoIniciado &&
                              mostrarFuncionalidadesCN)
                          ? 1.0
                          : 0.0, // Fica invisível se o jogo iniciou (mas mantém o tamanho se o nível for >= 7)
                      // Se você não quiser que esse espaço exista nas noites 1 a 6, usamos uma lógica simples:
                      child: (noiteAtual == 7)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tamanho: ",
                                    style: TextStyle(
                                      color: Colors.pinkAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.cyanAccent,
                                    ),
                                    onPressed: () {
                                      if (tamanhoCustomNight > 5 &&
                                          !mostrandoDeeDee) {
                                        setState(() {
                                          tamanhoCustomNight -= 2;
                                        });
                                      }
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.purpleAccent,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "$tamanhoCustomNight",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.cyanAccent,
                                    ),
                                    onPressed: () {
                                      if (tamanhoCustomNight < 29 &&
                                          !mostrandoDeeDee) {
                                        setState(() {
                                          tamanhoCustomNight += 2;
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (!mostrandoDeeDee) {
                                        aplicarCustomNight();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purpleAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text("APLICAR"),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(), // Se for noite < 7, não ocupa espaço nenhum
                    ),
                  ),

                  // LABIRINTO (Agora dentro de um Expanded para evitar empurrar o resto)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Cantos levemente arredondados na moldura
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
                            onPanUpdate: moverPorGesto,
                            onPanEnd: (_) {
                              _gestoProcessado = false;
                            },
                            child: AspectRatio(
                              aspectRatio: totalDeColunas / totalDeLinhas,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  9,
                                ), // Clip para os cantos internos
                                child: Stack(
                                  children: [
                                    GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: totalDeColunas,
                                          ),
                                      itemCount: totalDeLinhas * totalDeColunas,
                                      itemBuilder: (context, index) {
                                        int x = index % totalDeColunas;
                                        int y = index ~/ totalDeColunas;
                                        int valor = mapaDoLabirinto[y][x];

                                        BoxDecoration decoracao;
                                        Widget? widgetDaCelula;

                                        // LÓGICA DE VISÃO LIMITADA (Noite 6+)
                                        bool foraDoCampoDeVisao =
                                            (noiteAtual == 6 ||
                                                (noiteAtual == 7 &&
                                                    modoNightmareCustomNight)) &&
                                            ((x - posicaoPersonagemX).abs() >
                                                    1 ||
                                                (y - posicaoPersonagemY).abs() >
                                                    1);

                                        if (foraDoCampoDeVisao) {
                                          if (valor == 3) {
                                            // A pizza brilha no escuro! Mantemos o fundo escuro, mas renderizamos a imagem dela
                                            decoracao = BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.92,
                                              ),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 0,
                                              ),
                                            );
                                            widgetDaCelula = Image.asset(
                                              'assets/images/pizza.webp',
                                              fit: BoxFit.contain,
                                            );
                                          } else if (purpleGuyAtivo &&
                                              x == purpleGuyX &&
                                              y == purpleGuyY) {
                                            decoracao = BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.92,
                                              ),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 0,
                                              ),
                                            );
                                            widgetDaCelula = Image.asset(
                                              'assets/images/purple_guy.webp',
                                              fit: BoxFit.contain,
                                            );
                                          } else {
                                            // Se for qualquer outra coisa (parede ou caminho), fica totalmente escuro
                                            decoracao = BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.92,
                                              ),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 0,
                                              ),
                                            );
                                            widgetDaCelula = null;
                                          }
                                        } else {
                                          // --- SEU CÓDIGO ORIGINAL DE RENDERIZAÇÃO DAS CÉLULAS (Dentro do campo de visão) ---

                                          // 1. PAREDES DO LABIRINTO
                                          if (valor == 1) {
                                            decoracao = BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF3C006F),
                                                  Color(0xFF1A0033),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: Colors.purpleAccent
                                                    .withValues(alpha: 0.7),
                                                width: 0.8,
                                              ),
                                            );
                                          }
                                          // 2. PONTO DE SAÍDA / PORTA (Pizza)
                                          else if (valor == 3) {
                                            decoracao = BoxDecoration(
                                              color: Color(0xFF0D0D13),
                                              border: Border.all(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                width: 0.5,
                                              ),
                                            );
                                            widgetDaCelula = Image.asset(
                                              'assets/images/pizza.webp',
                                              fit: BoxFit.contain,
                                            );
                                          }
                                          // 3. CAMINHOS VAZIOS (A porta normal só pode nascer aqui)
                                          else {
                                            // Primeiro, verifica se há uma porta nesta célula vazia
                                            bool existePortaNestaCelula =
                                                posicoesPortas.any(
                                                  (p) =>
                                                      p['x'] == x &&
                                                      p['y'] == y,
                                                );

                                            if (existePortaNestaCelula) {
                                              widgetDaCelula = Image.asset(
                                                'assets/images/porta.webp',
                                                fit: BoxFit.contain,
                                              );

                                              decoracao = BoxDecoration(
                                                color: Color(0xFF0D0D13),
                                                border: Border.all(
                                                  color: Colors.purpleAccent
                                                      .withValues(alpha: 0.5),
                                                  width: 0.5,
                                                ),
                                              );
                                            } else {
                                              // Caminho vazio normal (sem porta)
                                              decoracao = BoxDecoration(
                                                color: Color(0xFF0D0D13),
                                                border: Border.all(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.5),
                                                  width: 0.5,
                                                ),
                                              );
                                            }
                                          }

                                          // PURPLE GUY (Mantido fora para renderizar por cima do caminho vazio)
                                          if (purpleGuyAtivo &&
                                              x == purpleGuyX &&
                                              y == purpleGuyY) {
                                            widgetDaCelula = Image.asset(
                                              'assets/images/purple_guy.webp',
                                              fit: BoxFit.contain,
                                            );

                                            decoracao = BoxDecoration(
                                              color: Color(0xFF0D0D13),
                                              border: Border.all(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                width: 0.5,
                                              ),
                                            );
                                          }

                                          // 4. PERSONAGEM / JOGADOR (Mantido fora para renderizar por cima de tudo)
                                          if (x == posicaoPersonagemX &&
                                              y == posicaoPersonagemY &&
                                              isJogadorVisivel) {
                                            widgetDaCelula = Image.asset(
                                              'assets/images/$_animatronico.webp',
                                              fit: BoxFit.contain,
                                            );
                                            decoracao = BoxDecoration(
                                              color: Color(0xFF0D0D13),
                                              border: Border.all(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                width: 0.5,
                                              ),
                                            );
                                          }
                                        }
                                        return Transform.scale(
                                          scale: foraDoCampoDeVisao ? 1.02 : 1,
                                          child: Container(
                                            margin: EdgeInsets.all(0.5),
                                            decoration: decoracao,
                                            child: widgetDaCelula,
                                          ),
                                        );
                                      },
                                    ),
                                    if (mostrandoMinireena)
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/images/minireena.webp',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize
                          .min, // Faz a Row ocupar apenas o espaço necessário
                      children: [
                        // Coluna 1 (Esquerda)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomCheckbox(
                              label: "MINIREENA",
                              variavel: temMinireenaCustomNight,
                              onChanged: (novoValor) {
                                if (!mostrandoDeeDee) {
                                  setState(
                                    () => temMinireenaCustomNight = novoValor,
                                  );
                                }
                              },
                            ),
                            _buildCustomCheckbox(
                              label: "PURPLE GUY",
                              variavel: temPurpleGuyCustomNight,
                              onChanged: (novoValor) {
                                if (!mostrandoDeeDee) {
                                  setState(
                                    () => temPurpleGuyCustomNight = novoValor,
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(
                          width: 10,
                        ), // Ajuste este valor para aproximar/afastar as colunas
                        // Coluna 2 (Meio)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomCheckbox(
                              label: "PORTAS",
                              variavel: temPortaCustomNight,
                              onChanged: (novoValor) {
                                if (!mostrandoDeeDee) {
                                  setState(
                                    () => temPortaCustomNight = novoValor,
                                  );
                                }
                              },
                            ),
                            _buildCustomCheckbox(
                              label: "HELPY",
                              variavel: temHelpyCustomNight,
                              onChanged: (novoValor) {
                                if (!mostrandoDeeDee) {
                                  setState(
                                    () => temHelpyCustomNight = novoValor,
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(
                          width: 10,
                        ), // Ajuste este valor para aproximar/afastar as colunas
                        // Coluna 3 (Direita)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomCheckbox(
                              label: "BALLOON BOY",
                              variavel: temBalloonBoyCustomNight,
                              onChanged: (novoValor) {
                                if (!mostrandoDeeDee) {
                                  setState(
                                    () => temBalloonBoyCustomNight = novoValor,
                                  );
                                }
                              },
                            ),
                            _buildCustomCheckbox(
                              label: "MODO NIGHTMARE",
                              variavel: modoNightmareCustomNight,
                              onChanged: (novoValor) {
                                if (!mostrandoDeeDee) {
                                  setState(() {
                                    modoNightmareCustomNight = novoValor;
                                    _exibirRuin = novoValor;
                                    iniciarEfeitoPiscada();
                                    _gerenciarMusicaAmbiente();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // HUD
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        hudTexto(
                          "NIGHT",
                          noiteAtual == 7 ? "7 (CN)" : "$noiteAtual",
                        ),
                        hudTexto(
                          "SIZE",
                          "${tamanhoAtualDaMatriz}x$tamanhoAtualDaMatriz",
                        ),
                        hudTexto("TIME", obterHorarioFnaf()),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Coluna dos botões de Ação
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: jogoIniciado
                                  ? null
                                  : () {
                                      // Se estiver na Custom Night E o número selecionado for diferente do labirinto gerado
                                      if (noiteAtual == 7 &&
                                          tamanhoCustomNight !=
                                              tamanhoAtualDaMatriz) {
                                        mostrarAvisoAplicar();
                                      } else {
                                        if (!purpleGuyPegou &&
                                            !mostrandoDeeDee) {
                                          iniciarJogo();
                                        }
                                      }
                                    },
                              icon: Icon(Icons.play_arrow, size: 18),
                              label: Text("START"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: !purpleGuyPegou && !mostrandoDeeDee
                                  ? reiniciarJogo
                                  : null,
                              icon: Icon(Icons.refresh, size: 18),
                              label: Text("RESET"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // D-PAD Otimizado (Apenas aparece se o jogo iniciou)
                        if (jogoIniciado) ...[
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: controleBotao(
                                    Icons.keyboard_arrow_up,
                                    () => moverPersonagem(0, -1),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: controleBotao(
                                    Icons.keyboard_arrow_left,
                                    () => moverPersonagem(-1, 0),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: controleBotao(
                                    Icons.keyboard_arrow_right,
                                    () => moverPersonagem(1, 0),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: controleBotao(
                                    Icons.keyboard_arrow_down,
                                    () => moverPersonagem(0, 1),
                                  ),
                                ),
                                if (mostrandoBalloonBoy)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      child: Image.asset(
                                        'assets/images/balloon_boy.webp',
                                        fit: BoxFit.contain,
                                      ),
                                      onTap: () async {
                                        await playerBtnBloqueado.play(
                                          AssetSource(
                                            'audios/btn_bloqueado.ogg',
                                          ),
                                          volume: 0.025,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Espaçador para manter o layout alinhado quando o D-Pad sumir
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Center(
                              child: Text(
                                "PRESS START",
                                style: TextStyle(
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

          // --- SUBSTITUA A LINHA ANTIGA DO HELPY POR ESTA ESTRUTURA: ---
          if (mostrandoHelpy)
            Positioned.fill(
              child: Align(
                alignment: Alignment(
                  (helpyPosicaoX * 2) -
                      1, // Converte escala 0..1 para o alinhamento do Flutter (-1..1)
                  (helpyPosicaoY * 2) - 1,
                ),
                child: GestureDetector(
                  onTap: clicarNoHelpy,
                  child: SizedBox(
                    width: 80, // Defina o tamanho ideal para o Helpy na tela
                    height: 80,
                    child: Image.asset(
                      helpyClicado
                          ? 'assets/images/helpy_clicado.webp'
                          : 'assets/images/helpy.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          if (mostrandoBalloon)
            Positioned(
              // Nova lógica: Subtrai metade do tamanho atual para centralizar o crescimento
              left:
                  (balloonPosicaoX * MediaQuery.of(context).size.width) -
                  (balloonWidth / 2),
              top:
                  (balloonPosicaoY * MediaQuery.of(context).size.height) -
                  (balloonWidth / 2),
              child: GestureDetector(
                onTap: () {
                  mostrandoBalloon = false;
                  _balloonMovimentoTimer?.cancel();
                  balloonEstourando();
                  iniciarCicloDoBalloonBoy();
                },
                child: Image.asset(
                  'assets/images/balloon.webp',
                  width: balloonWidth,
                  height:
                      balloonWidth, // Definir a altura igual ajuda a manter o círculo/quadrado perfeito
                  fit: BoxFit.contain,
                ),
              ),
            ),
          // Jumpscares / Imagens de fundo
          Center(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: !_exibirRuin
                    ? 0.25
                    : _moreOpacity
                    ? 0.5
                    : 0.3,
                child: _exibirRuin
                    ? Image.asset(
                        'assets/images/${_animatronico}_maze_ruin.webp',
                        height: 1000,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/${_animatronico}_maze.webp',
                        height: 1000,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          if (mostrandoJumpscare)
            Positioned.fill(
              child: Image.asset(
                'assets/images/${_animatronico}_jumpscare.webp',
                key: gifKey,
                fit: BoxFit.cover,
              ),
            ),
          if (mostrandoJumpscareHelpy)
            Positioned.fill(
              child: Image.asset(
                'assets/images/helpy_jumpscare.webp',
                key: gifKey,
                fit: BoxFit.cover,
              ),
            ),
          if (mostrando6AM)
            Positioned.fill(
              child: Image.asset(
                'assets/images/6am.webp',
                key: gifKey,
                fit: BoxFit.cover,
              ),
            ),

          // --- DEE DEE (sobe pela parte inferior) ---
          if (mostrandoDeeDee)
            Positioned(
              // Centraliza horizontalmente
              left: 0,
              right: 0,
              // A posição vertical: quando deeDeeOffsetY = 0, a base da imagem toca a base da tela.
              // Quando deeDeeOffsetY = 1, a imagem está completamente abaixo da tela.
              // bottom = -alturaDeeDee * deeDeeOffsetY faz ela subir de baixo para cima.
              bottom: -(alturaDeeDee * deeDeeOffsetY),
              child: Center(
                child: Image.asset(
                  'assets/images/dee_dee.webp',
                  width: larguraTela * 0.5,
                  height: alturaDeeDee,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // --- CHALLENGER (aparece no centro da tela) ---
          if (mostrandoChallenger)
            Positioned.fill(
              child: Center(
                child: Image.asset(
                  'assets/images/challenger.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // --- GOLDEN FREDDY (preenche a tela inteira, sobrepõe tudo) ---
          if (mostrandoGoldenFreddy)
            Positioned.fill(
              child: Image.asset(
                'assets/images/golden_freddy.webp',
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  // Widget do botão direcional atualizado (Menor e mais responsivo)
  Widget controleBotao(IconData icone, VoidCallback onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF240046),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 28, // Reduzido de 55 para 28
        color: Colors.white,
        icon: Icon(icone),
        onPressed: onPressed,
      ),
    );
  }

  Widget hudTexto(String titulo, String valor) {
    return Column(
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.pinkAccent,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 10)],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCheckbox({
    required String label,
    required bool variavel,
    required ValueChanged<bool> onChanged,
  }) {
    return IgnorePointer(
      ignoring: jogoIniciado,
      child: Opacity(
        opacity: (noiteAtual == 7 && !jogoIniciado && mostrarFuncionalidadesCN)
            ? 1.0
            : 0.0,
        child: (noiteAtual == 7)
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(!variavel),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Essencial para evitar erros de layout
                  children: [
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.purpleAccent,
                      ),
                      child: Checkbox(
                        value: variavel,
                        activeColor: Colors.purpleAccent,
                        checkColor: Colors.black,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        onChanged: (bool? valor) {
                          if (valor != null) {
                            onChanged(valor);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
