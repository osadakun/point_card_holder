import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/point_card.dart';
import '../services/storage_service.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({super.key, required this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ポイントカードホルダー'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.storageService.box.listenable(),
        builder: (context, Box<PointCard> box, _) {
          final cards = widget.storageService.getAllPointCards();

          if (cards.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ポイントカードが登録されていません',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '右下の＋ボタンから登録してください',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: cards.length,
            padding: const EdgeInsets.all(8),
            onReorder: (oldIndex, newIndex) async {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final card = cards.removeAt(oldIndex);
              cards.insert(newIndex, card);
              await widget.storageService.reorderPointCards(cards);
            },
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                key: ValueKey(card.id),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.credit_card,
                    size: 40,
                    color: Colors.blue,
                  ),
                  title: Text(
                    card.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: card.notes != null && card.notes!.isNotEmpty
                      ? Text(
                          card.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.drag_handle, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailScreen(
                          card: card,
                          storageService: widget.storageService,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddCardScreen(storageService: widget.storageService),
            ),
          );
        },
        tooltip: 'ポイントカードを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
