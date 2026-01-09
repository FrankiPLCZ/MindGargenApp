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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌿 TŁO (dopasuj asset do tego widoku)
        Container(
            color: Colors.green.shade100,
            alignment: Alignment.center,
          ),

        // 📜 PANEL Z LISTĄ
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ValueListenableBuilder<Box<DbItem>>(
                valueListenable: repo.listenable(),
                builder: (context, box, _) {
                  final items = repo.getAllSorted();

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'Brak zapisanych danych',
                        style: TextStyle(fontSize: 16),
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

                      return Container(
                        key: ValueKey(item.id),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => repo.deleteItem(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        // ➕ DOLNY PANEL DODAWANIA
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Dodaj wpis...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onPressed: _add,
                      child: const Text('Dodaj'),
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
    await repo.addItem(text);
    controller.clear();
  }
}
