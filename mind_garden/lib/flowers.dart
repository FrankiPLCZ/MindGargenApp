import 'package:flutter/material.dart';

/// --------------------
///  MODEL + ENUM
/// --------------------

enum FlowerType {
  sunflower,
  rose,
  lavender,
  daisy,
  custom,
}

extension FlowerTypeLabels on FlowerType {
  String get label {
    switch (this) {
      case FlowerType.sunflower:
        return "Słonecznik";
      case FlowerType.rose:
        return "Róża";
      case FlowerType.lavender:
        return "Lawenda";
      case FlowerType.daisy:
        return "Stokrotka";
      case FlowerType.custom:
        return "Inny kwiatek";
    }
  }
}

class MemoryEntry {
  final String id;
  final String description;
  final FlowerType? flower;
  final String? customImagePath;
  final DateTime createdAt;

  MemoryEntry({
    required this.id,
    required this.description,
    this.flower,
    this.customImagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// --------------------
///  BOTTOM SHEET UI
/// --------------------

class AddMemorySheet extends StatefulWidget {
  final void Function(MemoryEntry memory) onSave;

  const AddMemorySheet({super.key, required this.onSave});

  @override
  State<AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<AddMemorySheet>
    with SingleTickerProviderStateMixin {
  FlowerType? selectedFlower;
  String? imagePath;
  final TextEditingController controller = TextEditingController();

  late AnimationController _blastController;
  bool _isBlasting = false;

  @override
  void initState() {
    super.initState();

    _blastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _blastController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _blastController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dodaj wspomnienie 🌼",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // LISTA KWIATKÓW
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: FlowerType.values.map((flower) {
                final isSelected = selectedFlower == flower;

                return GestureDetector(
                  onTap: () => setState(() => selectedFlower = flower),
                  child: AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xffF8E6A0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xffE1C870)
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                  color: Colors.black.withOpacity(0.12),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_florist),
                          const SizedBox(height: 4),
                          Text(
                            flower.label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ZDJĘCIE (placeholder)
          GestureDetector(
            onTap: () {
              // TODO: podłącz image picker i ustaw imagePath
              // np. setState(() => imagePath = pickedFile.path);
            },
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  imagePath == null
                      ? "Dodaj własne zdjęcie 📸"
                      : "Zdjęcie dodane ✔️",
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // OPIS
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Opisz swoje wspomnienie...",
              filled: true,
              fillColor: const Color(0xffFFF1C7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // PRZYCISK ZAPISU
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF8C848),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isBlasting ? null : _onSavePressed,
            child: const Text(
              "Zapisz wspomnienie",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        Opacity(
          opacity: _isBlasting ? 0.3 : 1.0,
          child: IgnorePointer(
            ignoring: _isBlasting,
            child: content,
          ),
        ),
        if (_isBlasting)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blastController,
              builder: (context, child) {
                final t = _blastController.value;
                return Stack(
                  children: [
                    _buildFlyingFlower(
                      t,
                      const Offset(0, 40),
                      const Offset(-80, -160),
                      "🌼",
                    ),
                    _buildFlyingFlower(
                      t,
                      const Offset(0, 40),
                      const Offset(60, -140),
                      "🌸",
                    ),
                    _buildFlyingFlower(
                      t,
                      const Offset(0, 40),
                      const Offset(-40, -120),
                      "🌺",
                    ),
                    _buildFlyingFlower(
                      t,
                      const Offset(0, 40),
                      const Offset(90, -180),
                      "💮",
                    ),
                     _buildFlyingFlower(t, const Offset(0, 40), const Offset(-40, -120), "🌼"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(30, -130), "🌸"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(-70, -150), "🌺"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(60, -160), "💮"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(-100, -180), "🌻"),

            _buildFlyingFlower(t, const Offset(0, 40), const Offset(20, -110), "🌼"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(-20, -140), "🌸"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(80, -150), "🌺"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(-90, -170), "💮"),
            _buildFlyingFlower(t, const Offset(0, 40), const Offset(50, -190), "🌻"),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFlyingFlower(
    double t,
    Offset start,
    Offset end,
    String emoji,
  ) {
    final dx = start.dx + (end.dx - start.dx) * t;
    final dy = start.dy + (end.dy - start.dy) * t;
    final opacity = (1 - t).clamp(0.0, 1.0);
    final scale = 0.6 + 0.4 * t;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final memory = MemoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: text,
      flower: selectedFlower,
      customImagePath: imagePath,
    );

    widget.onSave(memory);

    setState(() {
      _isBlasting = true;
    });

    _blastController.forward(from: 0);
  }
  
}

/// --------------------
///  HELPER DO WYWOŁANIA
/// --------------------

void showAddMemorySheet(BuildContext context, void Function(MemoryEntry) onSave) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xffFFF5D9),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return AddMemorySheet(onSave: onSave);
    },
  );
}
List<MemoryEntry> memories = [];
