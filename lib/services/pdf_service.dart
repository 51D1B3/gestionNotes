import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateSemesterPdf(
      String semesterName,
      List<Map<String, dynamic>> subjects,
      double moyenneSemestre,
      String faculty,
      String department,
      String level,
      ) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle
        .load('assets/images/logo_universite_labe.png');
    final logo = pw.MemoryImage(
        logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [

              pw.Center(
                child: pw.Image(logo, height: 60),
              ),

              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text(
                  "RELEVÉ DE NOTES OFFICIEL",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Semestre : $semesterName"),
              pw.Text("Faculté : $faculty"),
              pw.Text("Département : $department"),
              pw.Text("Niveau : $level"),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ["Matière", "Coef", "Moyenne"],
                data: subjects.map((subject) {
                  return [
                    subject["name"],
                    subject["coefficient"].toString(),
                    (subject["moyenne"] as double)
                        .toStringAsFixed(2),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Moyenne Générale : ${moyenneSemestre.toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}