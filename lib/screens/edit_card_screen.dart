import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/point_card.dart';
import '../services/storage_service.dart';

class EditCardScreen extends StatefulWidget {
  final PointCard card;
  final StorageService storageService;

  const EditCardScreen({
    super.key,
    required this.card,
    required this.storageService,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _notesController;

  bool _isScanning = false;
  MobileScannerController? _scannerController;
  String? _detectedBarcodeFormat;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
    _barcodeController = TextEditingController(text: widget.card.barcode ?? '');
    _notesController = TextEditingController(text: widget.card.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _startQRScan() {
    setState(() {
      _isScanning = true;
      _scannerController = MobileScannerController();
    });
  }

  void _stopQRScan() {
    _scannerController?.dispose();
    setState(() {
      _isScanning = false;
      _scannerController = null;
    });
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _barcodeController.text = barcode.rawValue!;
          _detectedBarcodeFormat = barcode.format.name;
        });
        _stopQRScan();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バーコードを読み取りました')),
        );
      }
    }
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      widget.card.update(
        name: _nameController.text,
        barcode: _barcodeController.text.isNotEmpty
            ? _barcodeController.text
            : null,
        barcodeFormat: _barcodeController.text.isNotEmpty
            ? _detectedBarcodeFormat
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await widget.storageService.updatePointCard(widget.card);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ポイントカードを更新しました')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ポイントカード編集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isScanning ? _buildQRScanView() : _buildFormView(),
    );
  }

  Widget _buildQRScanView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController!,
          onDetect: _onDetect,
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: _stopQRScan,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('キャンセル'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'カード名',
                hintText: '例: スターバックス',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'カード名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'バーコード/QRコード (任意)',
                hintText: 'カメラで読み取るか、手動で入力',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _startQRScan,
                  tooltip: 'QRコードを読み取る',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'メモ (任意)',
                hintText: '例: 会員番号、有効期限など',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
