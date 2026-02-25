
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/screens/create_semester_screen.dart';
import '../services/firestore_service.dart';
import 'subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Semestres"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSemesters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Aucun semestre créé."),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Créer le premier semestre"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateSemesterScreen(hasExistingSemesters: false)),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final semesters = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              var semester = semesters[index];
              final semesterData = semester.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(semesterData['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('${semesterData['faculty']} - ${semesterData['department']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => service.deleteSemester(semester.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectScreen(
                          semesterId: semester.id,
                          semesterName: semesterData['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
         onPressed: () {
            // On vérifie à nouveau au cas où la liste est chargée mais le FAB est utilisé
            final hasSemesters = service.getSemesters().first.then((snap) => snap.docs.isNotEmpty);
            hasSemesters.then((value) {
                 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateSemesterScreen(hasExistingSemesters: value)),
                );
            });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

