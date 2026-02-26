
import 'package:flutter/material.dart';
import 'package:notes_app/screens/about_screen.dart';
import 'package:notes_app/screens/change_pin_screen.dart';
import 'package:notes_app/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Général", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Mode sombre'),
                secondary: const Icon(Icons.dark_mode),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => themeProvider.toggleTheme(value),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Changer le code PIN'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePinScreen())),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Données", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sauvegarde & Synchronisation'),
            onTap: () { /* Logique à implémenter */ },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () { /* Logique à implémenter */ },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Personnalisation", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            subtitle: const Text('Français'),
            onTap: () { /* Logique à implémenter */ },
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Taille de la police'),
            onTap: () { /* Logique à implémenter */ },
          ),
          const Divider(),
           ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('À propos'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}
