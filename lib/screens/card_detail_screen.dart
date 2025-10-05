import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/point_card.dart';
import '../services/storage_service.dart';
import 'edit_card_screen.dart';

class CardDetailScreen extends StatelessWidget {
  final PointCard card;
  final StorageService storageService;

  const CardDetailScreen({
    super.key,
    required this.card,
    required this.storageService,
  });

  Future<void> _deleteCard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${card.name}を削除しますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await storageService.deletePointCard(card.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ポイントカードを削除しました')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCardScreen(
                    card: card,
                    storageService: storageService,
                  ),
                ),
              );
            },
            tooltip: '編集',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteCard(context),
            tooltip: '削除',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  const Icon(
                    Icons.credit_card,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (card.barcode != null && card.barcode!.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'バーコード/QRコード',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: card.barcode!,
                        height: 100,
                        drawText: true,
                        errorBuilder: (context, error) {
                          // Code128が失敗した場合はQRコードを試す
                          return BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: card.barcode!,
                            width: 200,
                            height: 200,
                            errorBuilder: (context, error) {
                              // 全て失敗した場合はテキスト表示
                              return Center(
                                child: Text(
                                  card.barcode!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        card.barcode!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (card.notes != null && card.notes!.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'メモ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card.notes!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '登録日: ${_formatDate(card.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '更新日: ${_formatDate(card.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
