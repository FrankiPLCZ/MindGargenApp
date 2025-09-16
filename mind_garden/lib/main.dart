import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main(List<String> args) {
  runApp(MindGardenApp());
}

class MindGardenApp extends StatelessWidget {
  const MindGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_clean.png'), // lub inny plik z assets
              fit: BoxFit.fill,
            ),
          ),
          child: const RippleSpawner(),
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
  final List<Widget> _ripples = [];
  static const int maxRipples = 10;

  void _spawnRipple() {
    if (_ripples.length >= maxRipples) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limit osiągnięty'),
          content: const Text('Zespawnowałeś już 10 złych myśli. Skup się na nich najpierw zanim ruszysz dalej.'),
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
    setState(() {
      _ripples.add(RippleButton(
        key: UniqueKey(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Wyśrodkowane ripple'y
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _ripples,
          ),
        ),
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
  const RippleButton({super.key});

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
    setState(() {
      tapPosition = details.localPosition;
      _opacity = 0.0;
    });
    _controller.forward(from: 0);

    // Odtwórz dźwięk gong.wav z assets
    await _audioPlayer.play(AssetSource('gong1.wav'));

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _removed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_removed) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1500),
      child: GestureDetector(
        onTapDown: _startRipple,
        child: CustomPaint(
          painter: RipplePainter(
            animation: _controller,
            tapPosition: tapPosition,
            color: Colors.green,
          ),
          child: Container(
            height: size,
            width: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.lightGreen[50],
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Kliknij!',
              style: TextStyle(fontSize: 24),
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