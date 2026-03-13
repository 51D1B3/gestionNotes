import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'pin_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  String _selectedGender = 'Homme'; // Valeur par défaut
  bool _loading = false;

  void _saveProfile() async {
    String lastName = _lastNameController.text.trim().toUpperCase();
    String firstName = _firstNameController.text.trim();
    if (firstName.isNotEmpty) {
      firstName = firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
    }

    if (lastName.isEmpty || firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _loading = true);
    await _service.setProfile(lastName, firstName, _selectedGender);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuration du profil")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Color(0xFF0A3D62)),
              const SizedBox(height: 30),
              const Text(
                "Bienvenue ! Veuillez entrer vos informations pour commencer.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "NOM",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "Prénom",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              // Sélection du sexe
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sexe : ", style: TextStyle(fontSize: 16)),
                  Radio<String>(
                    value: 'Homme',
                    groupValue: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                  const Text("Homme"),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Femme',
                    groupValue: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                  const Text("Femme"),
                ],
              ),
              const SizedBox(height: 30),
              _loading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Enregistrer", style: TextStyle(fontSize: 18)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
