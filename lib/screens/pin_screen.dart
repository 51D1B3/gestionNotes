
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
      await _service.setPin(_controller.text);
      goToHome();
    } else if (_controller.text == savedPin) {
      goToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN incorrect")),
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                savedPin == null ? Icons.lock_open : Icons.lock_outline,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 30),
              Text(
                savedPin == null
                    ? "Créez votre code PIN à 4 chiffres"
                    : "Entrez votre code PIN",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validatePin,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                child: const Text("Valider"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
