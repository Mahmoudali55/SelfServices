import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// ===============================
/// Model
/// ===============================
class PrintSection {
  final String title;
  final Map<String, String> items;

  PrintSection({required this.title, required this.items});
}

/// ===============================
/// Utils
/// ===============================
class PdfPrintUtils {
  static Future<void> printDetails(
    BuildContext context,
    String title,
    List<PrintSection> sections,
  ) async {
    final doc = pw.Document();

    // Load Arabic font
    final fontData = await rootBundle.load('assets/font/Cairo-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final isAr = context.locale.languageCode == 'ar';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf, // مهم جدًا للعربي
        ),
        build: (_) {
          return pw.Directionality(
            textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),

                ...sections.map(
                  (section) => _buildSection(ttf, section.title, section.items, isAr),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: '${title.replaceAll(' ', '_')}.pdf',
      onLayout: (_) async => doc.save(),
    );
  }

  static pw.Widget _buildSection(pw.Font ttf, String title, Map<String, String> items, bool isAr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: ttf,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 6),

        ...items.entries.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    e.key,
                    style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey700),
                    textAlign: isAr ? pw.TextAlign.right : pw.TextAlign.left,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    (e.value.isEmpty ? '-' : e.value),
                    style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                    textAlign: isAr ? pw.TextAlign.right : pw.TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }
}
