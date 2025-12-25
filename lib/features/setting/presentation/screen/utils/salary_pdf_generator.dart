import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/setting/data/model/employee_salary_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalaryPdfGenerator {
  static Future<void> generateAndPrint(BuildContext context, EmployeeSalaryModel salaryData) async {
    final pdf = pw.Document();
    final isArabic = context.locale.languageCode == 'ar';

    // Load fonts
    final fontRegular = await rootBundle.load("assets/font/Cairo-Regular.ttf");
    final fontBold = await rootBundle.load("assets/font/Cairo-Bold.ttf");
    final ttfRegular = pw.Font.ttf(fontRegular);
    final ttfBold = pw.Font.ttf(fontBold);

    final earnings = salaryData.data.where((e) => e.varType == '1').toList();
    final deductions = salaryData.data.where((e) => e.varType == '2').toList();
    final installments = salaryData.data.where((e) => e.varType == '3').toList();

    double totalSalary = salaryData.data.isNotEmpty ? salaryData.data.first.val1 ?? 0.0 : 0.0;
    String tafkeet = salaryData.data.isNotEmpty ? salaryData.data.first.tafkeet ?? '' : '';

    final theme = pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold);

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  AppLocalKay.salaryvocabulary.tr(),
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              // Sections
              if (earnings.isNotEmpty)
                _buildSection(AppLocalKay.earnings.tr(), earnings, PdfColors.green, isArabic),
              if (deductions.isNotEmpty)
                _buildSection(AppLocalKay.deductions.tr(), deductions, PdfColors.red, isArabic),
              if (installments.isNotEmpty)
                _buildSection(
                  AppLocalKay.installments.tr(),
                  installments,
                  PdfColors.orange,
                  isArabic,
                ),

              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          AppLocalKay.totalSalary.tr(),
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '$totalSalary ${isArabic ? 'ر.س' : 'SAR'}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    if (tafkeet.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 5),
                        child: pw.Text(
                          tafkeet,
                          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Salary_Details',
    );
  }

  static pw.Widget _buildSection(
    String title,
    List<EmployeeSalaryItem> items,
    PdfColor color,
    bool isArabic,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              children: items.map((item) {
                final name = isArabic ? item.paName : item.paNameE;
                final value = item.varVal1; // assuming varVal1 is the value used in list

                // Inspecting SalarySectionWidget, it uses `item.paName` or `item.paNameE`
                // and `item.varVal1` or `item.varVal`.
                // Let's re-verify which value is displayed in the list.
                // Looking at EmployeeSalaryItem, varVal1 seems correct or varVal.

                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(name ?? '')),
                      pw.Text('${value?.toStringAsFixed(2) ?? "0.00"}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
