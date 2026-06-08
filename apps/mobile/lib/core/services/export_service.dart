import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  /// Export baby mon data to PDF
  Future<void> exportToPDF({
    required String title,
    required List<Map<String, dynamic>> data,
    String? subtitle,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            text: title,
          ),
          if (subtitle != null) pw.Paragraph(text: subtitle),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: data.isNotEmpty ? data.first.keys.toList() : [],
            data: data.map((row) => row.values.map((v) => v.toString()).toList()).toList(),
          ),
        ],
      ),
    );

    // Save and share
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$title.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(file.path)], text: 'BabyMon Export: $title');
  }

  /// Export baby mon data to image
  Future<void> exportToImage({
    required String title,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Header(level: 0, text: title),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: data.isNotEmpty ? data.first.keys.toList() : [],
              data: data.map((row) => row.values.map((v) => v.toString()).toList()).toList(),
            ),
          ],
        ),
      ),
    );

    // Convert to image and share
    final bytes = await pdf.save();
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$title.pdf');
    await file.writeAsBytes(bytes);
    
    await Share.shareXFiles([XFile(file.path)], text: 'BabyMon Export: $title');
  }

  /// Share text summary
  Future<void> shareTextSummary({
    required String title,
    required String content,
  }) async {
    await Share.share('$title\n\n$content', subject: title);
  }

  /// Print baby mon data
  Future<void> printData({
    required String title,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: title),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: data.isNotEmpty ? data.first.keys.toList() : [],
            data: data.map((row) => row.values.map((v) => v.toString()).toList()).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}