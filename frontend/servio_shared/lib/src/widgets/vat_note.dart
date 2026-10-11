import 'package:flutter/material.dart';

import '../theme/servio_colors.dart';
import '../utils/formatters.dart';
import '../localization/language.dart';

/// Menu prices include VAT, so it is never added on top; this line shows how much of [total] is VAT.
class VatNote extends StatelessWidget {
  const VatNote({super.key, required this.total, required this.taxRate, required this.currency, this.textAlign});

  final double total;

  /// In percent, e.g. 17.
  final double taxRate;
  final String currency;
  final TextAlign? textAlign;

  /// The VAT contained in [total], rounded like the server: 160.00 at 17% contains 23.25.
  static double includedTax(double total, double taxRate) =>
      taxRate <= 0 ? 0 : (total * taxRate / (100 + taxRate) * 100).roundToDouble() / 100;

  @override
  Widget build(BuildContext context) {
    final tax = includedTax(total, taxRate);
    final rate = taxRate == taxRate.roundToDouble() ? taxRate.toInt().toString() : taxRate.toString();
    return Text(
      l10n.vatIncluded(rate, Formatters.money(tax, currency), Formatters.money(total - tax, currency)),
      textAlign: textAlign,
      style: const TextStyle(color: ServioColors.textMuted, fontSize: 13),
    );
  }
}
