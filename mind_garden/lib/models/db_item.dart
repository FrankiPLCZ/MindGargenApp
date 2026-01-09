import 'package:hive/hive.dart';

part 'db_item.g.dart';

@HiveType(typeId: 1)
class DbItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  // zapis daty w ms od epoki (łatwe, stabilne)
  @HiveField(2)
  final int createdAtMs;

  const DbItem({
    required this.id,
    required this.title,
    required this.createdAtMs,
  });

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
}
