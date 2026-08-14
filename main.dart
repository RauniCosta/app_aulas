import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const VelocimetroApp());
}

class VelocimetroApp extends StatelessWidget {
  const VelocimetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocímetro Digital',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto', // Substitua pela sua fonte sans-serif preferida
      ),
      home: const VelocimetroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VelocimetroScreen extends StatefulWidget {
  const VelocimetroScreen({super.key});

  @override
  State<VelocimetroScreen> createState() => _VelocimetroScreenState();
}

class _VelocimetroScreenState extends State<VelocimetroScreen> {
  // Cores do CSS traduzidas
  final Color bgTop = const Color(0xFF111a2a);
  final Color bgBottom = const Color(0xFF04060b);
  final Color cyan = const Color(0xFF6bf5ff);
  final Color green = const Color(0xFF33e68c);
  final Color red = const Color(0xFFff5c72);
  final Color textDim = const Color(0xFF7385a1);
  final Color cardFill = const Color.fromRGBO(255, 255, 255, 0.035);

  // Estado da Aplicação (App State)
  bool _isTracking = false;
  int _elapsedSeconds = 0;
  double _distanceKm = 0.0;
  double _currentSpeedKmh = 0.0;
  
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  
  String _statusText = 'Aguardando';
  bool _hasError = false;

  // Formatação de Tempo (HH:MM:SS)
  String get _formattedTime {
    final h = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Velocidade Média
  int get _avgSpeed {
    if (_elapsedSeconds == 0) return 0;
    return (_distanceKm / (_elapsedSeconds / 3600)).round();
  }

  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setStatus('GPS desativado', isError: true);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setStatus('Permissão negada', isError: true);
        return;
      }
    }

    setState(() {
      _isTracking = true;
      _hasError = false;
      _statusText = 'Procurando sinal...';
    });

    // Inicia o Timer de duração
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Inicia a escuta do GPS
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      setState(() {
        _statusText = 'GPS ativo · ±${position.accuracy.round()}m';
        
        // No Flutter, o GPS já nos dá a velocidade em m/s. Convertendo para km/h:
        _currentSpeedKmh = (position.speed * 3.6).clamp(0.0, double.infinity);

        // Calcula a distância acumulada
        if (_lastPosition != null && position.accuracy <= 30) {
          double distanceMeters = Geolocator.distanceBetween(
            _lastPosition!.latitude, _lastPosition!.longitude,
            position.latitude, position.longitude,
          );
          _distanceKm += distanceMeters / 1000;
        }
        _lastPosition = position;
      });
    });
  }

  void _pauseTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    setState(() {
      _isTracking = false;
      _lastPosition = null; // Evita saltos de distância ao voltar
      _setStatus('Pausado', isError: false);
    });
  }

  void _resetTracking() {
    _pauseTracking();
    setState(() {
      _elapsedSeconds = 0;
      _distanceKm = 0;
      _currentSpeedKmh = 0;
      _setStatus('Aguardando', isError: false);
    });
  }

  void _setStatus(String text, {required bool isError}) {
    setState(() {
      _statusText = text;
      _hasError = isError;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildDisplayCard(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const Spacer(),
                _buildButtons(),
                const SizedBox(height: 24),
                Text(
                  'Usando GPS nativo do dispositivo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textDim, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'VELOCÍMETRO',
          style: TextStyle(
            color: textDim,
            fontSize: 13,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hasError ? red.withOpacity(0.16) : green.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _hasError ? red : green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _statusText,
                style: TextStyle(
                  color: _hasError ? const Color(0xFFffb3bf) : const Color(0xFFa9e9c4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: cyan.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: cyan.withOpacity(0.1),
            blurRadius: 60,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'VELOCIDADE ATUAL',
            style: TextStyle(color: textDim, fontSize: 12, letterSpacing: 1.5),
          ),
          Text(
            _currentSpeedKmh.round().toString(),
            style: TextStyle(
              fontSize: 100, // No Flutter usamos tamanho fixo ou MediaQuery
              fontWeight: FontWeight.w800,
              color: cyan,
              height: 1.0,
              shadows: [Shadow(color: cyan.withOpacity(0.55), blurRadius: 30)],
            ),
          ),
          const Text(
            'km/h',
            style: TextStyle(color: Color(0xFF8fbfc4), fontSize: 20, letterSpacing: 2.0),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('DISTÂNCIA', '${_distanceKm.toStringAsFixed(1)} km'),
        const SizedBox(width: 10),
        _buildStatItem('TEMPO', _formattedTime),
        const SizedBox(width: 10),
        _buildStatItem('VEL. MÉDIA', '$_avgSpeed km/h'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: textDim, fontSize: 10, letterSpacing: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _isTracking ? _pauseTracking() : _startTracking(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTracking ? Colors.transparent : green,
              foregroundColor: _isTracking ? red : const Color(0xFF052a1a),
              elevation: 0,
              side: _isTracking ? BorderSide(color: red) : BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _isTracking ? 'Pausar' : 'Iniciar',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isTracking ? null : _resetTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.04),
              foregroundColor: const Color(0xFFcdd6e4),
              elevation: 0,
              side: BorderSide(color: Colors.white.withOpacity(0.14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Resetar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}