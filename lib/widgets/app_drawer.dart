
import 'package:flutter/material.dart';
import 'package:notes_app/screens/faculties_screen.dart';
import 'package:notes_app/screens/help_screen.dart';
import 'package:notes_app/screens/history_screen.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:notes_app/screens/semesters_list_screen.dart';
import 'package:notes_app/screens/settings_screen.dart';
import 'package:notes_app/screens/statistics_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    // Utilisation du nom standard 'logo.png'
                    Image.asset('assets/logo.png', height: 80),
                    const SizedBox(height: 10),
                    const Text('UniNotes', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Moyennes des Semestres'),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const SemestersListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistiques'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
            },
          ),
           ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Facultés'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FacultiesScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Exporter en PDF'),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique'),
            onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
          ),
           const Divider(),
           ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide'),
            onTap: () {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
            },
          ),
        ],
      ),
    );
  }
}
