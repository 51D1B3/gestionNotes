import 'package:flutter/material.dart';
import 'package:notes_app/services/history_service.dart';
import 'package:open_file/open_file.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<String>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = _historyService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _historyService.clearHistory();
              _refreshHistory();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No history found.".tr()));
          }

          final history = snapshot.data!;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final filePath = history[index];
              final fileName = filePath.split('/').last;
              
              // Extraction des infos depuis le nom du fichier (UniNotes_Semestre_X_TIMESTAMP.pdf)
              // On peut essayer d'en extraire quelque chose de plus lisible
              final parts = fileName.split('_');
              String displayTitle = fileName;
              String displaySubtitle = "";
              
              if(parts.length >= 3) {
                displayTitle = parts[1].replaceAll('+', ' '); // Le nom du semestre
                if(parts.length >= 4) {
                   final timestamp = int.tryParse(parts[2]);
                   if(timestamp != null) {
                      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                      displaySubtitle = DateFormat('dd/MM/yyyy HH:mm').format(date);
                   }
                }
              }

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(displayTitle),
                subtitle: Text(displaySubtitle),
                onTap: () => OpenFile.open(filePath),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () async {
                    await _historyService.removeFromHistory(filePath);
                    _refreshHistory();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
