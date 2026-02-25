import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {

  final oldController = TextEditingController();
  final newController = TextEditingController();
  final service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier PIN")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: oldController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Ancien PIN"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: newController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Nouveau PIN"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                bool ok = await service.verifyPin(oldController.text);

                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ancien PIN incorrect")),
                  );
                  return;
                }

                await service.updatePin(newController.text);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN modifié")),
                );

                Navigator.pop(context);
              },
              child: const Text("Valider"),
            )
          ],
        ),
      ),
    );
  }
}