import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/setting/data/model/time_sheet_model.dart';
import 'package:my_template/features/setting/presentation/screen/utils/time_sheet_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TimeSheetPdfGenerator {
  static Future<void> generateAndPrint(
    BuildContext context,
    List<TimeSheetModel> timeSheets,
    DateTime date,
  ) async {
    final pdf = pw.Document();
    final isArabic = context.locale.languageCode == 'ar' || context.locale.languageCode == 'ur';
    final isUrdu = context.locale.languageCode == 'ur';
    final isRtl = isArabic || isUrdu;

    // Load fonts
    final fontRegular = await rootBundle.load('assets/font/Cairo-Regular.ttf');
    final fontBold = await rootBundle.load('assets/font/Cairo-Bold.ttf');
    final ttfRegular = pw.Font.ttf(fontRegular);
    final ttfBold = pw.Font.ttf(fontBold);

    final theme = pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold);

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape, // Landscape for more columns
        textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  '${AppLocalKay.timesheet.tr()} - $formattedDate',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Project
                  1: const pw.FlexColumnWidth(1.5), // Date
                  2: const pw.FlexColumnWidth(1), // In
                  3: const pw.FlexColumnWidth(1), // Out
                  4: const pw.FlexColumnWidth(1), // Proj In
                  5: const pw.FlexColumnWidth(1), // Proj Out
                  6: const pw.FlexColumnWidth(0.8), // Delay
                  7: const pw.FlexColumnWidth(0.8), // Extra
                  8: const pw.FlexColumnWidth(0.8), // Work
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildHeaderCell(AppLocalKay.project.tr()),
                      _buildHeaderCell(AppLocalKay.Date.tr()),
                      _buildHeaderCell(AppLocalKay.CheckIn.tr()),
                      _buildHeaderCell(AppLocalKay.CheckOut.tr()),
                      _buildHeaderCell(AppLocalKay.ProjectCheckIn.tr()),
                      _buildHeaderCell(AppLocalKay.ProjectCheckout.tr()),
                      _buildHeaderCell(AppLocalKay.delay.tr()),
                      _buildHeaderCell(AppLocalKay.extra.tr()),
                      _buildHeaderCell(AppLocalKay.totalWork.tr()),
                    ],
                  ),
                  // Data Rows
                  ...timeSheets.map((item) {
                    final calc = TimeSheetCalculator(item, date);

                    return pw.TableRow(
                      children: [
                        _buildCell(item.nameGpf),
                        _buildCell(item.signInDate),
                        _buildCell(item.signInTime ?? '-'),
                        _buildCell(item.signOutTime ?? '-'),
                        _buildCell(item.projectSignInTime.toString()),
                        _buildCell(item.projectSignOutTime.toString()),
                        _buildCell(TimeSheetCalculator.formatDuration(calc.delay)),
                        _buildCell(TimeSheetCalculator.formatDuration(calc.overtime)),
                        _buildCell(
                          calc.actualSignOut != null
                              ? TimeSheetCalculator.formatDuration(calc.workDuration)
                              : '-',
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'TimeSheet_$formattedDate',
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
    );
  }
}
