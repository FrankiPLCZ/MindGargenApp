// models/memory_entry.dart

import 'package:flutter/material.dart';

enum FlowerType {
  sunflower,
  rose,
  lavender,
  daisy,
  custom, // np. własny rysunek / inny typ
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
  final String? customImagePath; // np. ścieżka z ImagePicker
  final DateTime createdAt;

  MemoryEntry({
    required this.id,
    required this.description,
    this.flower,
    this.customImagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}



class AddMemorySheet extends StatefulWidget {
  @override
  State<AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<AddMemorySheet> {
  FlowerType? selectedFlower;
  String? imagePath;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dodaj wspomnienie 🌼",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // wybór kwiatka
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: FlowerType.values.map((flower) {
                return GestureDetector(
                  onTap: () => setState(() => selectedFlower = flower),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedFlower == flower
                          ? const Color(0xffF8E6A0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedFlower == flower
                            ? const Color(0xffE1C870)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.local_florist, color: Colors.green.shade700),
                        Text(flower.name),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // zdjęcie
          GestureDetector(
            onTap: () {
              // TODO: dodać image picker
            },
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(imagePath == null
                    ? "Dodaj własne zdjęcie 📸"
                    : "Zdjęcie dodane ✔️"),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // opis
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

          // przycisk zapisu
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF8C848),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              final memory = MemoryEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                description: controller.text,
                flower: selectedFlower,
                customImagePath: imagePath,
              );
              print("object created");
              print(memory.flower);
              Navigator.of(context).pop();
              // TODO: zapisać memory do bazy / listy
            },
            child: const Text(
              "Zapisz wspomnienie",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

  void showAddMemorySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xffFFF5D9), // pastel żółty jak w tle
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return AddMemorySheet();
    },
  );
}

