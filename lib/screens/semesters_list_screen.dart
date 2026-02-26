
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/firestore_service.dart';

class SemestersListScreen extends StatelessWidget {
  const SemestersListScreen({super.key});

  int _getMentionValue(String mention) {
    switch (mention) {
      case "Très bien": return 4;
      case "Bien": return 3;
      case "Assez bien": return 2;
      case "Passable": return 1;
      default: return 0;
    }
  }

 String _getOverallMention(double average) {
    if (average < 1) return "Echec";
    if (average < 2) return "Passable";
    if (average < 3) return "Assez bien";
    if (average < 4) return "Bien";
    return "Très bien";
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moyennes des Semestres'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSemesters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun semestre à afficher."));
          }

          final semesters = snapshot.data!.docs;

          return ListView.builder(
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              final semester = semesters[index];
              final semesterData = semester.data() as Map<String, dynamic>;

              return FutureBuilder<QuerySnapshot>(
                future: service.getSubjects(semester.id).first,
                builder: (context, subjectSnapshot) {
                  if (!subjectSnapshot.hasData) return const ListTile(title: Text("..."));

                  int mentionSum = 0;
                  int subjectCount = subjectSnapshot.data!.docs.length;
                  for (var doc in subjectSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    mentionSum += _getMentionValue(data['mention'] ?? 'Echec');
                  }
                  
                  double average = (subjectCount > 0) ? mentionSum / subjectCount : 0;
                  String overallMention = _getOverallMention(average);

                  return Card(
                     margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: ListTile(
                      title: Text(semesterData['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Chip(
                        label: Text('Moy: ${average.toStringAsFixed(2)} - $overallMention'),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
