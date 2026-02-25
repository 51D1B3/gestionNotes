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
    setState(() {
      loading = false;
    });
  }

  void validatePin() async {
    if (_controller.text.length != 4) return;

    if (savedPin == null) {
      await _service.setPin(_controller.text);
      goToHome();
    } else if (_controller.text == savedPin) {
      goToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN incorrect")),
      );
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
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                savedPin == null
                    ? "Créer votre code PIN (4 chiffres)"
                    : "Entrer votre code PIN",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validatePin,
                child: const Text("Valider"),
              )
            ],
          ),
        ),
      ),
    );
  }
}