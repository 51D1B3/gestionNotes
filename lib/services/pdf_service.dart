
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfService {
  Future<String> generateSemesterPdf(
    String semesterName,
    List<Map<String, dynamic>> subjects,
    double average,
    String faculty, 
    String department,
    String level
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Relevé de notes - $semesterName', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Faculté: $faculty'),
              pw.Text('Département: $department'),
              pw.Text('Niveau: $level'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Matière', 'Note Examen', 'Note DG', 'Note Final', 'Moyenne', 'Mention'],
                data: subjects.map((s) => [
                  s['name'],
                  s['ne'].toStringAsFixed(2),
                  s['ndg'].toStringAsFixed(2),
                  s['nef'].toStringAsFixed(2),
                  s['moyenneMatiere'].toStringAsFixed(2),
                  s['mention'],
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Moyenne du semestre: ${average.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final Directory? downloadsDir = await getExternalStorageDirectory();
    final String path = '${downloadsDir!.path}/releve_$semesterName.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    
    return path;
  }
}
