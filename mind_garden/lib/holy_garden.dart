import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mind_garden/flowers.dart';

import 'data/repository.dart';
import 'models/db_item.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage>
    with AutomaticKeepAliveClientMixin<GardenPage> {
  final repo = GetIt.I<ItemsRepository>();

  // Stabilne przypisanie: item.id -> pozycja (proporcje ekranu)
  final Map<String, Offset> _posById = {};
  final Set<Offset> _occupied = {};

  @override
  bool get wantKeepAlive => true;

    Widget _gardenFlower(String path, {double size = 90}) {
    final p = path.trim();

    // asset → jak było
    if (p.startsWith('assets/')) {
      return Image.asset(
        p,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    // file (custom) → zdjęcie w środku + ramka kwiatu
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.file(
              File(p),
              width: size * 0.64,   // dostrój pod “dziurę” w ramce
              height: size * 0.64,
              fit: BoxFit.cover,
            ),
          ),
          Image.asset(
            kCustomFrameAsset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }


  ImageProvider _imageProvider(String path) {
    final p = path.trim();
    if (p.startsWith('assets/')) return AssetImage(p);
    return FileImage(File(p));
  }

  void _reconcilePositions(List<DbItem> items) {
    final currentIds = items.map((e) => e.id).toSet();

    // usuń pozycje dla rekordów, których już nie ma (np. wypadły z 24h albo skasowane)
    final toRemove = _posById.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in toRemove) {
      final pos = _posById.remove(id);
      if (pos != null) _occupied.remove(pos);
    }

    // przypisz pozycje dla nowych rekordów
    final random = Random();
    for (final item in items) {
      if (_posById.containsKey(item.id)) continue;

      final free = flowerPositions.where((p) => !_occupied.contains(p)).toList();
      if (free.isEmpty) break;

      final chosen = free[random.nextInt(free.length)];
      _posById[item.id] = chosen;
      _occupied.add(chosen);
    }
  }

  void showMemorySheet(
  BuildContext context,
  DbItem item,
  ImageProvider image,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      final maxH = MediaQuery.of(context).size.height * 0.78;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    // uchwyt
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ✅ STAŁY OBRAZ (nie scrolluje)
                    Container(
                      width: 170,
                      height: 170,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image(image: image, fit: BoxFit.contain),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ (opcjonalnie) stały tytuł — możesz wywalić jeśli title jest długie
                    Text(
                      'Wspomnienie',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF2B2B2B).withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🔽 SCROLLOWANY TEKST
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.40),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.35,
                              color: Color(0xFF2B2B2B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // stały przycisk
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7C948),
                          foregroundColor: const Color(0xFF2B2B2B),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Zamknij',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      // ✅ identyczna logika tła jak u Ciebie na stronie głównej
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/holy_garden_clean.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: SafeArea(
        child: ValueListenableBuilder<Box<DbItem>>(
          valueListenable: repo.listenable(),
          builder: (context, box, _) {
            final items = repo.getFreshLast5(); // 5 z <=24h

            // dopasuj mapę pozycji do aktualnych elementów
            _reconcilePositions(items);

            if (items.isEmpty) {
              return Center(
                child: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFFFF6D8), // bardzo jasny krem
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFFE2D3A3), // ciepła ramka
      width: 2,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: const Text(
    'Brak kwiatów z ostatnich 24h 🌱',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: Color(0xFF5A5A2E), // oliwkowy, nie czarny
    ),
  ),
)
,
              );
            }

            final screen = MediaQuery.of(context).size;
            final w = screen.width;
            final h = screen.height;

            const flowerSize = 90.0;
            
            return Stack(
              children: [
                for (final item in items)
                  if ((item.flowerImagePath ?? '').trim().isNotEmpty && _posById[item.id] != null)
                    () {
                      final path = item.flowerImagePath!.trim();
                      final img = _imageProvider(path);

                      return Positioned(
                        left: w * _posById[item.id]!.dx - (flowerSize / 2),
                        top: h * _posById[item.id]!.dy - (flowerSize / 2),
                        child: GestureDetector(
                          onTap: () => showMemorySheet(context, item, img),
                            child: _gardenFlower(
                              item.flowerImagePath!.trim(),
                              size: flowerSize,
                            ),
                        ),
                      );
                    }(),
              ],
            );

          },
        ),
      ),
    );
  }
}

final List<Offset> flowerPositions = [
  Offset(0.18, 0.65),
  Offset(0.32, 0.78),
  Offset(0.72, 0.62),
  Offset(0.75, 0.77),
  Offset(0.85, 0.69),
];

