import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mind_garden/data/repository.dart';
import '../models/db_item.dart';

class DbManagementPage extends StatefulWidget {
  @override
  State<DbManagementPage> createState() => _DbManagementPageState();
}

class _DbManagementPageState extends State<DbManagementPage> {
  final repo = GetIt.I<ItemsRepository>();
  final controller = TextEditingController();

  // 🎨 Spójna paleta
  static const _bg1 = Color(0xFFFFF4D6); // główne tło (krem)
  static const _bg2 = Color(0xFFFFF4D6); // zostaw takie samo
  static const _bg3 = Color.fromARGB(255, 250, 249, 245); // żeby gradient był neutralny

  static const _cream = Color(0xFFFFF4D6); // krem bazowy
  static const _gold = Color(0xFFF7C948);  // żółty przycisk
  static const _textDark = Color(0xFF2B2B2B); // tekst

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 🔁 asset vs file → jeden provider
  ImageProvider _imageProvider(String path) {
    final p = path.trim();
    if (p.startsWith('assets/')) return AssetImage(p);
    return FileImage(File(p));
  }

  // 🌼 Ikonka kwiatka do kafelka listy
  Widget _buildFlowerIcon(String? path) {
    if (path == null || path.trim().isEmpty) {
      return const SizedBox(width: 40, height: 40);
    }
    final p = path.trim();

    final Widget image = p.startsWith('assets/')
        ? Image.asset(p, width: 32, height: 32, fit: BoxFit.contain)
        : Image.file(File(p), width: 32, height: 32, fit: BoxFit.cover);

    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _cream.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: image,
      ),
    );
  }

  // 🌌 Bottom sheet: obrazek stały, tekst scroll
  void _showItemSheet(BuildContext context, DbItem item) {
    final path = (item.flowerImagePath ?? '').trim();
    if (path.isEmpty) return;

    final img = _imageProvider(path);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final maxH = MediaQuery.of(context).size.height * 0.82;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Container(
              decoration: BoxDecoration(
                color: _bg2.withOpacity(0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _cream.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
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
                          color: _cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // obrazek stały
                      Container(
                        width: 170,
                        height: 170,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _bg3.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: _cream.withOpacity(0.14)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image(image: img, fit: BoxFit.contain),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // nagłówek (na razie stały)
                      Text(
                        'Wspomnienie',
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 0.6,
                          color: _textDark.withOpacity(0.75),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // przewijany tekst
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _bg3.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _cream.withOpacity(0.14)),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.38,
                                color: _textDark.withOpacity(0.92),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: _textDark,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Zamknij',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                        ],
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
    return Stack(
      children: [
        // 🌌 Kosmiczno-medytacyjne tło
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bg1, _bg2, _bg3],
            ),
          ),
        ),

        // 📜 Panel z listą
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Container(
              decoration: BoxDecoration(
                color: _cream.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ValueListenableBuilder<Box<DbItem>>(
                valueListenable: repo.listenable(),
                builder: (context, box, _) {
                  final items = repo.getAllSorted();

                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Brak zapisanych danych',
                        style: TextStyle(
                          fontSize: 16,
                          color: _textDark.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    primary: false,
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = items[i];

                      return InkWell(
                        key: ValueKey(item.id),
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showItemSheet(context, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFlowerIcon(item.flowerImagePath),
                              const SizedBox(width: 12),

                              // ✅ max 4 linie + ...
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    height: 1.25,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: _textDark.withOpacity(0.75),
                                onPressed: () => repo.deleteItem(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        // ➕ Dolny panel dodawania
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cream.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Dodaj wpis...',
                          hintStyle: TextStyle(color: _textDark.withOpacity(0.45)),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _textDark,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        elevation: 0,
                      ),
                      onPressed: _add,
                      child: const Text(
                        'Dodaj',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _add() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    await repo.addItem(text, "assets/sunflower.png");
    controller.clear();
  }
}
