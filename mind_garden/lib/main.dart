import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mind_garden/data/repository.dart';
import 'package:mind_garden/db_page.dart';
import 'package:mind_garden/flowers.dart';
import 'package:mind_garden/holy_garden.dart';
import 'package:mind_garden/models/db_item.dart';
import 'package:shared_preferences/shared_preferences.dart';


// globalna blokada ripple
final ValueNotifier<bool> rippleButtonBlocked = ValueNotifier<bool>(false);

final getIt = GetIt.instance;




Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DbItemAdapter());

  await Hive.openBox<DbItem>(ItemsRepository.boxName);

  getIt.registerSingleton<ItemsRepository>(ItemsRepository());
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
      home: FirstLaunchGate(),
    );
  }
}

class FirstLaunchGate extends StatefulWidget {
  const FirstLaunchGate({super.key});

  @override
  State<FirstLaunchGate> createState() => _FirstLaunchGateState();
}

class _FirstLaunchGateState extends State<FirstLaunchGate> {
  static const _firstLaunchKey = 'is_first_launch_done';
  bool? _shouldShowOnboarding;

  @override
  void initState() {
    super.initState();
    _loadFirstLaunchState();
  }

  Future<void> _loadFirstLaunchState() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchDone = prefs.getBool(_firstLaunchKey) ?? false;

    if (!mounted) return;
    setState(() {
      _shouldShowOnboarding = !firstLaunchDone;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);

    if (!mounted) return;
    setState(() {
      _shouldShowOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldShowOnboarding == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_shouldShowOnboarding == true) {
      return OnboardingPage(onFinish: _finishOnboarding);
    }

    return const MindGardenHome();
  }
}

class OnboardingPage extends StatefulWidget {
  final Future<void> Function() onFinish;

  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _lastPageValue = 0;
  int _scrollDirection = 1;

  final List<({
    String title,
    String description,
    IconData icon,
    String backgroundAsset,
    bool enterFromRight,
  })> _pages = [
    (
      title: 'Witaj w Mind Garden',
      description:
          'Chwasty to twoje nieświadome myśli, zamieniaj je codziennie w piękne kwiaty aż twój ogród rozkwitnie i zmieni twoje życie w świadome bycie tu i teraz',
      icon: Icons.spa_outlined,
      backgroundAsset: 'assets/background_clean.png',
      enterFromRight: true,
    ),
    (
      title: 'Dodawaj chwasty',
      description:
          'Na głównym ekranie kliknij „Dodaj chwast”. Pojawi się chwast, który reprezentuje myśl do przepracowania.',
      icon: Icons.add_circle_outline,
      backgroundAsset: 'assets/background_clean_slide1_5.png',
      enterFromRight: true,
    ),
    (
      title: 'Pracuj z emocją',
      description:
          'Kliknij chwast, aby przejść dalej i zastąpić go pięknym wspomnieniem. Po zapisie zobaczysz je w swoim ogrodzie.',
      icon: Icons.self_improvement_outlined,
      backgroundAsset: 'assets/background_clean_slide2.png',
      enterFromRight: true,
    ),
        (
      title: 'Dbaj o swój ogród',
      description:
          'W ogrodzie wyświetlają się kwiaty dodane w ostatnich 24h. Dbaj o to aby twój ogród był zawsze pełny a umysł spokojny',
      icon: Icons.local_florist,
      backgroundAsset: 'assets/holy_garden.png',
      enterFromRight: true,
    ),
        (
      title: 'Zarządzaj swoimi kwiatami',
      description:
          'W panelu z lewej strony przeglądaj lub usuwaj swoje kwiaty',
      icon: Icons.agriculture,
      backgroundAsset: 'assets/db_background.png',
      enterFromRight: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextOrFinish() async {
    if (_currentPage == _pages.length - 1) {
      await widget.onFinish();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = _currentPage.toDouble();

        if (_pageController.hasClients) {
          page = _pageController.page ?? _currentPage.toDouble();
        }

        final clampedPage = page.clamp(0.0, (_pages.length - 1).toDouble());

        if (clampedPage > _lastPageValue) {
          _scrollDirection = 1;
        } else if (clampedPage < _lastPageValue) {
          _scrollDirection = -1;
        }
        _lastPageValue = clampedPage;

        final lowerIndex = clampedPage.floor();
        final upperIndex = clampedPage.ceil();
        final transition = clampedPage - lowerIndex;

        int currentIndex = lowerIndex;
        int nextIndex = upperIndex;
        double progress = transition;

        if (_scrollDirection < 0) {
          currentIndex = upperIndex;
          nextIndex = lowerIndex;
          progress = 1 - transition;
        }

        final nextEntersFromRight = _pages[nextIndex].enterFromRight;
        final beginOffsetX = nextEntersFromRight ? 1.0 : -1.0;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _pages[currentIndex].backgroundAsset,
                fit: BoxFit.fill,
              ),
              if (nextIndex != currentIndex)
                FractionalTranslation(
                  translation: Offset(beginOffsetX * (1 - progress), 0),
                  child: Opacity(
                    opacity: progress,
                    child: Image.asset(
                      _pages[nextIndex].backgroundAsset,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedBackground(),
          Container(
            color: Colors.black.withOpacity(0.08),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onFinish,
                    child: const Text('Pomiń'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(page.icon,
                                    size: 52, color: Colors.green[700]),
                                const SizedBox(height: 16),
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(fontSize: 16, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Colors.green[700]
                            : Colors.green[200],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ElevatedButton(
                    onPressed: _nextOrFinish,
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Zaczynajmy'
                          : 'Dalej',
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
    showAddMemorySheet(context,(memory) {
      // co ma się stać po zapisaniu wspomnienia
      setState(() {
        memories.add(memory);
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: [
          // strona 0
          DbManagementPage(),
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
          GardenPage(),
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
            child:         ElevatedButton(
  onPressed: _spawnRipple, // albo () {}, jeśli nie używasz callbacka
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFF0E6C8), // jasny kamień
    foregroundColor: const Color(0xFF4E412A), // tekst
    elevation: 3,
    shadowColor: const Color(0xFFB09A6A),
    padding: const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(
        color: Color(0xFF9E8757), // kontrastowa obwódka
        width: 2,
      ),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/Chwast1.png', // rysunkowa emotka chwasta
        width: 22,
        height: 22,
      ),
      const SizedBox(width: 10),
      const Text(
        'Dodaj chwast',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    ],
  ),
)
,
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
    await _audioPlayer.setVolume(0.1);
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
