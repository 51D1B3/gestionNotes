
import 'package:flutter/material.dart';
import 'package:notes_app/services/firestore_service.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();

  bool _isOldPinVerified = false;

  void _verifyOldPin() async {
    if (_oldPinController.text.length != 4) return;

    final isCorrect = await _service.verifyPin(_oldPinController.text);
    if (isCorrect) {
      setState(() {
        _isOldPinVerified = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ancien PIN incorrect."), backgroundColor: Colors.red),
      );
    }
  }

  void _updatePin() async {
    if (_newPinController.text.length != 4) return;

    await _service.updatePin(_newPinController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Code PIN mis à jour avec succès."), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer le code PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isOldPinVerified)
              ...[
                const Text("Entrez votre ancien code PIN", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                TextField(
                  controller: _oldPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ''),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _verifyOldPin, child: const Text("Vérifier")),
              ]
            else
              ...[
                const Text("Entrez votre nouveau code PIN", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                TextField(
                  controller: _newPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                   textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ''),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _updatePin, child: const Text("Mettre à jour")),
              ],
          ],
        ),
      ),
    );
  }
}
