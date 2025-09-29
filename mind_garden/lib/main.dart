import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

// Dodaj globalną zmienną blokady
final ValueNotifier<bool> rippleButtonBlocked = ValueNotifier<bool>(false);

void main(List<String> args) {
  runApp(MindGardenApp());
}

class MindGardenApp extends StatelessWidget {
  const MindGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 1);
    return MaterialApp(
      home: Scaffold(
        body:PageView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: [
                Container(
                  color: Colors.green.shade100,
                  alignment: Alignment.center,
                  child: const Text(
                  "Hello tutaj twoje staty 🌱",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage('assets/background_clean.png'), // lub inny plik z assets
                  fit: BoxFit.fill,
            ),
          ),
                  child: const RippleSpawner(),
                      ),
                Container(
                  color: Colors.green.shade100,
                  alignment: Alignment.center,
                  child: const Text(
                  "Hello tutaj rajski ogród 🌱",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),                
          ],
        ),


      ),
    );
  }
}

class RippleSpawner extends StatefulWidget {
  const RippleSpawner({super.key});

  @override
  State<RippleSpawner> createState() => _RippleSpawnerState();
}

class _RippleSpawnerState extends State<RippleSpawner> {
  final List<RippleButton> _ripples = []; // <-- Popraw z List<Widget> na List<RippleButton>
  final List<Offset> _occupiedPositions = [];

  void _spawnRipple() {
    if (_ripples.length >= 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limit osiągnięty'),
          content: const Text('Możesz mieć tylko 5 aktywnych guzików naraz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Filtruj wolne pozycje
    final freePositions = buttonPositions.where((pos) => !_occupiedPositions.contains(pos)).toList();
    if (freePositions.isEmpty) return; // nie ma wolnych miejsc

    final random = Random();
    final pos = freePositions[random.nextInt(freePositions.length)];

    setState(() {
      _occupiedPositions.add(pos);
      final rippleKey = UniqueKey();
      _ripples.add(RippleButton(
        key: rippleKey,
        xProportion: pos.dx,
        yProportion: pos.dy,
        onRemove: () {
          setState(() {
            _ripples.removeWhere((r) => r.key == rippleKey);
            _occupiedPositions.remove(pos);
          });
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        ..._ripples.map((ripple) => Positioned(
          left: screenWidth * ripple.xProportion,
          top: screenHeight * ripple.yProportion,
          child: ripple,
        )),
        // Przycisk na dole ekranu
        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: Center(
            child: ElevatedButton(
              onPressed: _spawnRipple,
              child: const Text('Dodaj guzik'),
            ),
          ),
        ),
      ],
    );
  }
}

class RippleButton extends StatefulWidget {
  final double xProportion;
  final double yProportion;
  final VoidCallback onRemove;
  const RippleButton({
    super.key,
    required this.xProportion,
    required this.yProportion,
    required this.onRemove,
  });

  @override
  State<RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton> with TickerProviderStateMixin {
  final double size = 100;
  Offset? tapPosition;
  late AnimationController _controller;
  double _opacity = 1.0;
  bool _removed = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Dodaj AudioPlayer

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // zwolnij zasoby AudioPlayer
    super.dispose();
  }

  void _startRipple(TapDownDetails details) async {
    if (rippleButtonBlocked.value) {
      // Możesz dodać dialog z informacją o blokadzie
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Uwaga'),
          content: const Text('Skup się na jednej myśli naraz. Poczekaj 10 sekund przed kolejnym kliknięciem.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // rippleButtonBlocked.value = true; // ustaw blokadę

    setState(() {
      tapPosition = details.localPosition;
      _opacity = 0.0;
    });
    _controller.forward(from: 0);

    // Odtwórz dźwięk gong.wav z assets
    await _audioPlayer.play(AssetSource('gong1.wav'));

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onRemove();
      }
    });

    // Odblokuj po 10 sekundach
    Future.delayed(const Duration(seconds: 10), () {
      rippleButtonBlocked.value = false;
    });
  }

@override
Widget build(BuildContext context) {
  if (_removed) return const SizedBox.shrink();

  return AnimatedOpacity(
    opacity: _opacity,
    duration: const Duration(milliseconds: 1500),
    child: GestureDetector(
      onTapDown: _startRipple, // TapDownDetails -> void _startRipple(TapDownDetails d)
      child: CustomPaint(
        painter: RipplePainter(
          animation: _controller,
          tapPosition: tapPosition,
          color: Colors.green,
        ),
        child: SizedBox(
          height: size,
          width: size,
          child: Center(
            child: Image.asset(
              'assets/Chwast1.png',
              fit: BoxFit.contain,
              height: size,
              width: size,
            ),
          ),
        ),
      ),
    ),
  );
}
}

class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset? tapPosition;
  final Color color;

  RipplePainter({
    required this.animation,
    required this.tapPosition,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition == null) return;

    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Rysuj kilka okręgów o różnych promieniach
    for (int i = 0; i < 3; i++) {
      final progress = (animation.value - i * 0.2).clamp(0.0, 1.0);
      if (progress > 0) {
        final radius = maxRadius * progress;
        // Im bliżej końca animacji, tym bardziej przezroczysty okrąg
        final fade = (1.0 - progress).clamp(0.0, 1.0);
        canvas.drawCircle(
          tapPosition!,
          radius,
          paint..color = color.withOpacity((0.25 - i * 0.07) * fade),
        );
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.tapPosition != tapPosition;
}

final List<Offset> buttonPositions = [
  Offset(0.25, 0.75),
  Offset(0.5, 0.5),
  Offset(0.7, 0.4),
  Offset(0.72, 0.58),
  Offset(0.54, 0.68),
];