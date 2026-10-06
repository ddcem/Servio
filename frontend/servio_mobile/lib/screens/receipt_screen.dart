import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';

/// The guest's receipt as the server renders it, ready to show, share or print.
class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.paymentId, required this.title});

  final int paymentId;
  final String title;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late Future<Uint8List> _pdf = _load();

  Future<Uint8List> _load() => context.read<PaymentProvider>().getReceiptPdf(widget.paymentId);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: GradientAppBar(title: 'Receipt', subtitle: widget.title),
    body: FutureBuilder<Uint8List>(
      future: _pdf,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error!, onRetry: () => setState(() => _pdf = _load()));
        }
        if (!snapshot.hasData) return const LoadingView();
        final bytes = snapshot.data!;
        return PdfPreview(
          build: (_) async => bytes,
          pdfFileName: 'servio-receipt-${widget.paymentId}.pdf',
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          maxPageWidth: 420,
          scrollViewDecoration: const BoxDecoration(color: ServioColors.background),
        );
      },
    ),
  );
}
