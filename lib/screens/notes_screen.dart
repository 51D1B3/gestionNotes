import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatelessWidget {
  final String semesterId;
  final String subjectId;
  final String subjectName;

  const NotesScreen({
    super.key,
    required this.semesterId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final neController = TextEditingController();
    final ndgController = TextEditingController();
    final nefController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes - $subjectName"),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: service.getNotes(semesterId, subjectId),
        builder: (context, snapshot) {

          double moyenne = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!;
            moyenne = data["moyenneMatiere"];
            neController.text = data["Ne"].toString();
            ndgController.text = data["Ndg"].toString();
            nefController.text = data["Nef"].toString();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: neController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Note Examen"),
                ),
                TextField(
                  controller: ndgController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Devoir Groupe"),
                ),
                TextField(
                  controller: nefController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Examen Final"),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    await service.addOrUpdateNotes(
                      semesterId,
                      subjectId,
                      double.parse(neController.text),
                      double.parse(ndgController.text),
                      double.parse(nefController.text),
                    );
                  },
                  child: const Text("Calculer & Sauvegarder"),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A3D62),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Moyenne Matière",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        moyenne.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A3D62),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          // Action à définir
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}