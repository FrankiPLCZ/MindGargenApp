import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/db_item.dart';

class ItemsRepository {
  static const boxName = 'items_box';
  static const ttl = Duration(days: 1); // 24h

  Box<DbItem> get _box => Hive.box<DbItem>(boxName);

  // do reaktywnego UI (nasłuch zmian)
  ValueListenable<Box<DbItem>> listenable() => _box.listenable();

  Future<void> addItem(String title, String flower) async {
    final item = DbItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      flowerImagePath: flower,
    );
    await _box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  // WIDOK A: wszystko
  List<DbItem> getAllSorted() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return items;
  }

  // WIDOK B: tylko świeże (<= 24h) — NIC NIE KASUJEMY
  List<DbItem> getFreshSorted() {
    final now = DateTime.now();
    final items = _box.values.where((e) {
      return now.difference(e.createdAt) <= ttl;
    }).toList();

    items.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return items;
  }
}
