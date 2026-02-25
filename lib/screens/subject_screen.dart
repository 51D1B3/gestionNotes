
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';

class SubjectScreen extends StatelessWidget {
  final String semesterId;
  final String semesterName;

  const SubjectScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  String _getMention(double moyenne) {
    if (moyenne < 5) return "Echec";
    if (moyenne <= 5.99) return "Passable";
    if (moyenne <= 6.99) return "Assez bien";
    if (moyenne <= 7.99) return "Bien";
    return "Très bien";
  }

  void _showNoteDialog(BuildContext context, {DocumentSnapshot? subject}) {
    final service = FirestoreService();
    final nameController = TextEditingController(text: subject?['name']);
    final neController = TextEditingController(text: subject != null ? subject['ne'].toString() : '');
    final ndgController = TextEditingController(text: subject != null ? subject['ndg'].toString() : '');
    final nefController = TextEditingController(text: subject != null ? subject['nef'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject == null ? 'Ajouter une matière' : 'Modifier la matière'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom de la matière')),
              TextField(controller: neController, decoration: const InputDecoration(labelText: 'Note d\'examen (Ne)'), keyboardType: TextInputType.number),
              TextField(controller: ndgController, decoration: const InputDecoration(labelText: 'Devoir de groupe (Ndg)'), keyboardType: TextInputType.number),
              TextField(controller: nefController, decoration: const InputDecoration(labelText: 'Examen final (Nef)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Annuler'), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text('Valider'),
            onPressed: () async {
              final name = nameController.text;
              final ne = double.tryParse(neController.text) ?? 0.0;
              final ndg = double.tryParse(ndgController.text) ?? 0.0;
              final nef = double.tryParse(nefController.text) ?? 0.0;

              if (name.isNotEmpty) {
                final moyenneMatiere = ne * 0.35 + ndg * 0.25 + nef * 0.40;
                final mention = _getMention(moyenneMatiere);
                
                if (subject == null) {
                  await service.addSubjectWithNotes(semesterId, name, ne, ndg, nef, moyenneMatiere, mention);
                } else {
                  await service.updateSubjectWithNotes(semesterId, subject.id, name, ne, ndg, nef, moyenneMatiere, mention);
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Matières - $semesterName"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
                // La logique PDF devra être mise à jour pour gérer la nouvelle structure
                // var data = await service.getSemesterDataForPdf(semesterId);
                // await PdfService().generateSemesterPdf(semesterName, data["subjects"], data["moyenneSemestre"], data["faculty"], data["department"], data["level"]);
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La génération PDF doit être adaptée.')),
                 );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSubjects(semesterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune matière. Appuyez sur + pour en ajouter une."));
          }

          final subjects = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Matière', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Ne', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Ndg', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Nef', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Moyenne', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Mention', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: subjects.map((subject) {
                final data = subject.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Text(data['name'] ?? '')),
                    DataCell(Text(data['ne']?.toStringAsFixed(2) ?? '0.0')),
                    DataCell(Text(data['ndg']?.toStringAsFixed(2) ?? '0.0')),
                    DataCell(Text(data['nef']?.toStringAsFixed(2) ?? '0.0')),
                    DataCell(Text(data['moyenneMatiere']?.toStringAsFixed(2) ?? '0.0')),
                    DataCell(Text(data['mention'] ?? '')),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showNoteDialog(context, subject: subject)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => service.deleteSubject(semesterId, subject.id)),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
