// import 'package:flutter/material.dart';

// void main(List<String> args) {
//   runApp(MindGardenApp());

// }

// class MindGardenApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Welcome to Mind Garden'),
//           backgroundColor: Colors.green,
//           foregroundColor: Colors.black,
//         ),
//         body: Center(
//           child: Container(
//             height: 300,
//             width: 300,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.lightGreen[50],
//             border: Border.all(color: Colors.green, width: 2),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(50),
//               splashColor: const Color.fromARGB(255, 204, 240, 105).withOpacity(0.8), // kolor animacji
//               onTap: () {
//                 // tutaj możesz dodać swoją logikę po kliknięciu
//               },
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:math';

void main(List<String> args) {
  runApp(MindGardenApp());
}

class MindGardenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Mind Garden'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: RippleButton(),
        ),
      ),
    );
  }
}

class RippleButton extends StatefulWidget {
  @override
  State<RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton> with TickerProviderStateMixin {
  final double size = 200;
  Offset? tapPosition;
  late AnimationController _controller;

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
    super.dispose();
  }

  void _startRipple(TapDownDetails details) {
    setState(() {
      tapPosition = details.localPosition;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          child: Text(
            'Kliknij!',
            style: TextStyle(fontSize: 24),
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