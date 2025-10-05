import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/point_card.dart';

class StorageService {
  static const String _boxName = 'pointCards';
  static const String _encryptionKeyName = 'encryptionKey';

  Box<PointCard>? _box;

  Future<void> init() async {
    await Hive.initFlutter();

    // Generate or retrieve encryption key
    final keyBox = await Hive.openBox(_encryptionKeyName);
    Uint8List encryptionKey;

    if (keyBox.isEmpty) {
      // Generate new encryption key (32 bytes for AES-256)
      encryptionKey = Uint8List.fromList(
        List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch % 256),
      );
      await keyBox.put('key', encryptionKey);
    } else {
      final storedKey = keyBox.get('key');
      encryptionKey = storedKey is Uint8List
          ? storedKey
          : Uint8List.fromList(List<int>.from(storedKey));
    }

    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PointCardAdapter());
    }

    // Open box with encryption
    _box = await Hive.openBox<PointCard>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Box<PointCard> get box {
    if (_box == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _box!;
  }

  Future<void> addPointCard(PointCard card) async {
    await box.put(card.id, card);
  }

  Future<void> updatePointCard(PointCard card) async {
    await card.save();
  }

  Future<void> deletePointCard(String id) async {
    await box.delete(id);
  }

  PointCard? getPointCard(String id) {
    return box.get(id);
  }

  List<PointCard> getAllPointCards() {
    final cards = box.values.toList();
    cards.sort((a, b) => a.order.compareTo(b.order));
    return cards;
  }

  Future<void> reorderPointCards(List<PointCard> cards) async {
    for (int i = 0; i < cards.length; i++) {
      cards[i].order = i;
      await updatePointCard(cards[i]);
    }
  }

  Future<void> close() async {
    await _box?.close();
  }
}
