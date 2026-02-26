
import 'package:flutter/material.dart';
import 'package:notes_app/screens/about_screen.dart';
import 'package:notes_app/screens/backup_screen.dart';
import 'package:notes_app/screens/change_pin_screen.dart';
import 'package:notes_app/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showFontSizeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Taille de la police"),
          content: SizedBox(
            height: 200,
            width: 100,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              perspective: 0.005,
              diameterRatio: 1.2,
              onSelectedItemChanged: (index) => provider.setFontSize((8 + index).toDouble()),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final size = 8 + index;
                  return Center(child: Text(size.toString(), style: TextStyle(fontSize: 20)));
                },
                childCount: 13, // 8 to 20
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choisir la langue"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("Français"), onTap: () { provider.setLocale(const Locale('fr')); Navigator.pop(context); }),
            ListTile(title: const Text("English"), onTap: () { provider.setLocale(const Locale('en')); Navigator.pop(context); }),
            ListTile(title: const Text("العربية"), onTap: () { provider.setLocale(const Locale('ar')); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
           SwitchListTile(
              title: const Text('Mode sombre'),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ListTile(
            leading: const Icon(Icons.lock), 
            title: const Text('Changer le code PIN'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePinScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sauvegarde & Synchronisation'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            subtitle: Text(themeProvider.locale.languageCode == 'fr' ? "Français" : (themeProvider.locale.languageCode == 'en' ? "English" : "العربية")),
            onTap: () => _showLanguageDialog(context, themeProvider),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Taille de la police'),
            subtitle: Text(themeProvider.fontSize.toInt().toString()),
            onTap: () => _showFontSizeDialog(context, themeProvider),
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
