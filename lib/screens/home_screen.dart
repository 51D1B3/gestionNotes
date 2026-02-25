
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/screens/create_semester_screen.dart';
import '../services/firestore_service.dart';
import 'subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Aide"),
        content: Text("Appuyez sur + pour créer un semestre."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      drawer: const Drawer(
        child: Center(child: Text("Menu")),
      ),
      appBar: AppBar(
        title: const Text("Gestion des Semestres"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showHelp(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getSemesters(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var semesters = snapshot.data!.docs;

          if (semesters.isEmpty) {
            return const Center(
              child: Text("Aucun semestre créé"),
            );
          }

          return ListView.builder(
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              var semester = semesters[index];

              return Card(
                       elevation: 4,
                       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: ListTile(
                         contentPadding: const EdgeInsets.all(16),
                         title: Text(
                           semester["name"],
                           style: const TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         subtitle: Text(
                           semester["createdAt"]
                               .toDate()
                               .toString(),
                         ),
                         trailing: IconButton(
                           icon: const Icon(Icons.delete, color: Colors.red),
                           onPressed: () {
                             service.deleteSemester(semester.id);
                           },
                         ),
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => SubjectScreen(
                                 semesterId: semester.id,
                                 semesterName: semester["name"],
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSemesterScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
