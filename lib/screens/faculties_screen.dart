
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultiesScreen extends StatelessWidget {
  const FacultiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facultés et Départements'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('faculties').orderBy('name').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune faculté n'a été trouvée."));
          }

          final faculties = snapshot.data!.docs;

          return ListView.builder(
            itemCount: faculties.length,
            itemBuilder: (context, index) {
              final faculty = faculties[index];
              final facultyData = faculty.data() as Map<String, dynamic>;
              final List<dynamic> departments = facultyData['departments'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(facultyData['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: departments.map((dept) {
                    return ListTile(
                      title: Text(dept.toString()),
                      contentPadding: const EdgeInsets.only(left: 30.0),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
