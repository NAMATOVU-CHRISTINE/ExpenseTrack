import 'dart:io';
import 'package:flutter/material.dart';
import '../services/receipt_service.dart';

class ReceiptImagePicker extends StatelessWidget {

  const ReceiptImagePicker({
    super.key,
    this.receiptPath,
    required this.onReceiptChanged,
  });
  final String? receiptPath;
  final Function(String?) onReceiptChanged;

  @override
  Widget build(BuildContext context) {
    final hasReceipt =
        receiptPath != null && ReceiptService.receiptExists(receiptPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        if (hasReceipt) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(receiptPath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _ActionButton(
                      icon: Icons.fullscreen,
                      onTap: () => _viewFullScreen(context),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.delete,
                      onTap: () => _removeReceipt(),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showPickerOptions(context),
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Receipt Photo',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await ReceiptService.pickReceiptFromCamera();
                onReceiptChanged(path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await ReceiptService.pickReceiptFromGallery();
                onReceiptChanged(path);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ReceiptFullScreenView(receiptPath: receiptPath!),
      ),
    );
  }

  void _removeReceipt() async {
    await ReceiptService.deleteReceipt(receiptPath);
    onReceiptChanged(null);
  }
}

class _ActionButton extends StatelessWidget {

  const _ActionButton({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color ?? Colors.white, size: 20),
        ),
      ),
    );
  }
}

class ReceiptFullScreenView extends StatelessWidget {

  const ReceiptFullScreenView({super.key, required this.receiptPath});
  final String receiptPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Receipt', style: TextStyle(color: Colors.white)),
      ),
      body: InteractiveViewer(
        child: Center(child: Image.file(File(receiptPath))),
      ),
    );
  }
}
