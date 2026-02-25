
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

  void _showDeleteConfirmation(BuildContext context, String subjectId) {
    final service = FirestoreService();
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette matière ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Oui'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                service.deleteSubject(semesterId, subjectId);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoteDialog(BuildContext context, {DocumentSnapshot? subject}) {
    final service = FirestoreService();
    final nameController = TextEditingController(text: subject?['name']);
    final neController = TextEditingController(text: subject != null ? subject['ne'].toString() : '');
    final ndgController = TextEditingController(text: subject != null ? subject['ndg'].toString() : '');
    final nefController = TextEditingController(text: subject != null ? subject['nef'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subject == null ? 'Ajouter une matière' : 'Modifier la matière', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom de la matière')),
                TextField(controller: neController, decoration: const InputDecoration(labelText: 'Note Examen'), keyboardType: TextInputType.number),
                TextField(controller: ndgController, decoration: const InputDecoration(labelText: 'Devoir de Groupe'), keyboardType: TextInputType.number),
                TextField(controller: nefController, decoration: const InputDecoration(labelText: 'Examen Final'), keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(child: const Text('Annuler'), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(semesterName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
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
            return const Center(child: Text("Aucune matière. Appuyez sur + pour ajouter.", textAlign: TextAlign.center,));
          }

          final subjects = snapshot.data!.docs;

          return SingleChildScrollView(
             padding: const EdgeInsets.only(top: 8.0),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.8)),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                  }
                  return null; // Use default
                }
              ),
              columns: const [
                DataColumn(label: Text('Matière', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Notes E', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Notes G', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Notes F', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Moyenne', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Mention', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
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
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showNoteDialog(context, subject: subject)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, subject.id)),
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
        backgroundColor: Theme.of(context).primaryColor, // Couleur bleue
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
