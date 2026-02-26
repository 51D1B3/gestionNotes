
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comment utiliser l\'application', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('1. Créez un semestre depuis l\'écran d\'accueil.\n'
                 '2. Ajoutez des matières à votre semestre.\n'
                 '3. Entrez vos notes pour chaque matière.\n'
                 '4. Consultez vos statistiques et exportez vos relevés.'),
          ],
        ),
      ),
    );
  }
}
