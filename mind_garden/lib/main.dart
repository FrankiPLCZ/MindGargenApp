import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:mind_garden/flowers.dart';

// globalna blokada ripple
final ValueNotifier<bool> rippleButtonBlocked = ValueNotifier<bool>(false);

void main(List<String> args) {
  runApp(const MindGardenApp());
}

// ---------------------------
//     MIND GARDEN APP
// ---------------------------
class MindGardenApp extends StatelessWidget {
  const MindGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MindGardenHome(),
    );
  }
}

// ---------------------------
//       HOME (PageView)
// ---------------------------
class MindGardenHome extends StatefulWidget {
  const MindGardenHome({super.key});

  @override
  State<MindGardenHome> createState() => _MindGardenHomeState();
}

class _MindGardenHomeState extends State<MindGardenHome> {
  final PageController _controller = PageController(initialPage: 1);

  // wywoływane z ripple (strona 1)
  void _goToPage2() async {
    // 1. animacja do strony 2
    await _controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    if (!mounted) return;

    // 2. małe opóźnienie, żeby mieć pewność, że wszystko się przerysowało
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // 3. odpalamy dialog z BEZPIECZNEGO kontekstu (MindGardenHome)
    showAddMemorySheet(context);
  }

  // osobna funkcja do obsługi dialogu – nie jest powiązana z ripple
  // void _openMemoryDialog() async {
  //   final TextEditingController opisController = TextEditingController();

  //   final String? result = await showDialog<String>(
  //     context: context,
  //     builder: (ctx) {
  //       return AlertDialog(
  //         title: const Text('Dodaj wspomnienie 🌱'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text('Opisz swoje wspomnienie:'),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: opisController,
  //               maxLines: 4,
  //               decoration: const InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: 'Np. spacer po lesie, zapach deszczu...',
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(ctx).pop(null); // anuluj
  //             },
  //             child: const Text('Anuluj'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               final tekst = opisController.text.trim();
  //               Navigator.of(ctx).pop(tekst); // zwróć tekst
  //             },
  //             child: const Text('Zapisz'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   // opisController.dispose();

  //   // jeśli użytkownik coś wpisał i kliknął "Zapisz"
  //   if (result != null && result.trim().isNotEmpty) {
  //     debugPrint('Zapisane wspomnienie: $result');
  //     showAddMemorySheet(context);
  //     // TODO: tutaj możesz dodać to wspomnienie do listy / wysłać na backend itd.
  //     // np. setState(() { _memories.add(result); });
  //   }
  // }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: [
          // strona 0
          Container(
            color: Colors.green.shade100,
            alignment: Alignment.center,
            child: const Text(
              "Hello tutaj twoje staty 🌱",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          // strona 1
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_clean.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: RippleSpawner(
              onGoToPage2: _goToPage2,
            ),
          ),
          // strona 2
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/holy_garden_clean.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
//       RIPPLE SPAWNER
// ---------------------------
class RippleSpawner extends StatefulWidget {
  final VoidCallback onGoToPage2;

  const RippleSpawner({
    super.key,
    required this.onGoToPage2,
  });

  @override
  State<RippleSpawner> createState() => _RippleSpawnerState();
}

class _RippleSpawnerState extends State<RippleSpawner>
    with AutomaticKeepAliveClientMixin<RippleSpawner> {
  final List<RippleButton> _ripples = [];
  final List<Offset> _occupiedPositions = [];

  @override
  bool get wantKeepAlive => true;

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

    final freePositions = buttonPositions
        .where((pos) => !_occupiedPositions.contains(pos))
        .toList();
    if (freePositions.isEmpty) return;

    final random = Random();
    final pos = freePositions[random.nextInt(freePositions.length)];

    setState(() {
      _occupiedPositions.add(pos);
      final rippleKey = UniqueKey();
      _ripples.add(
        RippleButton(
          key: rippleKey,
          xProportion: pos.dx,
          yProportion: pos.dy,
          onRemove: () {
            setState(() {
              _ripples.removeWhere((r) => r.key == rippleKey);
              _occupiedPositions.remove(pos);
            });
          },
          onGoToPage2: widget.onGoToPage2,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ważne przy AutomaticKeepAliveClientMixin

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        ..._ripples.map(
          (ripple) => Positioned(
            left: screenWidth * ripple.xProportion,
            top: screenHeight * ripple.yProportion,
            child: ripple,
          ),
        ),
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

// ---------------------------
//       RIPPLE BUTTON
// ---------------------------
class RippleButton extends StatefulWidget {
  final double xProportion;
  final double yProportion;
  final VoidCallback onRemove;
  final VoidCallback onGoToPage2;

  const RippleButton({
    super.key,
    required this.xProportion,
    required this.yProportion,
    required this.onRemove,
    required this.onGoToPage2,
  });

  @override
  State<RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton>
    with TickerProviderStateMixin {
  final double size = 100;
  Offset? tapPosition;
  late AnimationController _controller;
  double _opacity = 1.0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startRipple(TapDownDetails details) async {
    if (rippleButtonBlocked.value) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Uwaga'),
          content: const Text(
            'Skup się na jednej myśli naraz. Poczekaj 10 sekund przed kolejnym kliknięciem.',
          ),
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

    rippleButtonBlocked.value = true;
    Timer(const Duration(seconds: 10), () {
      rippleButtonBlocked.value = false;
    });

    // po 1 sekundzie: przejście na stronę 2 + dialog (logika w _goToPage2)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) widget.onGoToPage2();
    });

    setState(() {
      tapPosition = details.localPosition;
      _opacity = 0.0;
    });

    _controller.forward(from: 0);

    await _audioPlayer.play(AssetSource('gong1.wav'));

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
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

// ---------------------------
//       RIPPLE PAINTER
// ---------------------------
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

    final maxRadius =
        sqrt(size.width * size.width + size.height * size.height);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (int i = 0; i < 3; i++) {
      final progress = (animation.value - i * 0.2).clamp(0.0, 1.0);

      if (progress > 0) {
        final radius = maxRadius * progress;
        final fade = (1.0 - progress).clamp(0.0, 1.0);

        canvas.drawCircle(
          tapPosition!,
          radius,
          basePaint
            ..color = color.withOpacity((0.25 - i * 0.07) * fade),
        );
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.tapPosition != tapPosition;
}

// ---------------------------
//   PRZYPISANE POZYCJE
// ---------------------------
final List<Offset> buttonPositions = [
  Offset(0.25, 0.75),
  Offset(0.5, 0.5),
  Offset(0.7, 0.4),
  Offset(0.72, 0.58),
  Offset(0.54, 0.68),
];
