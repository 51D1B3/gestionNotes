
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UniNotes', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Description de l\'auteur', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Cette application a été développée avec passion pour aider les étudiants à organiser et suivre leurs résultats académiques de manière simple et efficace.',
            ),
          ],
        ),
      ),
    );
  }
}
