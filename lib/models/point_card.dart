import 'package:hive/hive.dart';

part 'point_card.g.dart';

@HiveType(typeId: 0)
class PointCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? barcode;

  @HiveField(3)
  String? barcodeFormat;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  int order;

  PointCard({
    required this.id,
    required this.name,
    this.barcode,
    this.barcodeFormat,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.order = 0,
  });

  factory PointCard.create({
    required String name,
    String? barcode,
    String? barcodeFormat,
    String? notes,
    int order = 0,
  }) {
    final now = DateTime.now();
    return PointCard(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      barcode: barcode,
      barcodeFormat: barcodeFormat,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      order: order,
    );
  }

  void update({
    String? name,
    String? barcode,
    String? barcodeFormat,
    String? notes,
  }) {
    if (name != null) this.name = name;
    if (barcode != null) this.barcode = barcode;
    if (barcodeFormat != null) this.barcodeFormat = barcodeFormat;
    if (notes != null) this.notes = notes;
    updatedAt = DateTime.now();
  }
}
