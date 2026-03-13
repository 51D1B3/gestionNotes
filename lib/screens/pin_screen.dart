import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _controller = TextEditingController();

  String? savedPin;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPin();
  }

  Future<void> loadPin() async {
    savedPin = await _service.getPin();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void validatePin() async {
    if (_controller.text.length != 4) return;

    if (savedPin == null) {
      // Cas du 1er lancement : Création du PIN
      await _service.setPin(_controller.text);
      // Redirection immédiate
      goToHome();
    } else if (_controller.text == savedPin) {
      // Cas classique : Vérification du PIN
      goToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN incorrect"), backgroundColor: Colors.red),
      );
      _controller.clear();
    }
  }

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                savedPin == null ? Icons.lock_open : Icons.lock_outline,
                size: 100, // Taille ajustée pour être bien visible
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 30),
              Text(
                savedPin == null
                    ? "Créez votre code PIN à 4 chiffres"
                    : "Entrez votre code PIN",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, letterSpacing: 20),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onSubmitted: (_) => validatePin(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: validatePin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Valider", style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
