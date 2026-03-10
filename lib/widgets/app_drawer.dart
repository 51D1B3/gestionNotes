import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/screens/faculties_screen.dart';
import 'package:notes_app/screens/help_screen.dart';
import 'package:notes_app/screens/history_screen.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:notes_app/screens/semesters_list_screen.dart';
import 'package:notes_app/screens/settings_screen.dart';
import 'package:notes_app/screens/statistics_screen.dart';
import 'package:notes_app/widgets/custom_page_route.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Center(
              child: ClipOval(
                child: Image.asset('assets/applogo.png', height: 100, width: 100, fit: BoxFit.cover),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text('Home'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, CustomPageRoute(builder: (context) => const HomeScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: Text('Semester Averages'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CustomPageRoute(builder: (context) => const SemestersListScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: Text('Faculties'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CustomPageRoute(builder: (context) => const FacultiesScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: Text('Statistics'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CustomPageRoute(builder: (context) => const StatisticsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text('History'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CustomPageRoute(builder: (context) => const HistoryScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text('settings_title'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CustomPageRoute(builder: (context) => const SettingsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text('Help'.tr()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CustomPageRoute(builder: (context) => const HelpScreen()));
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Exit'.tr(), style: const TextStyle(color: Colors.red)),
            onTap: () => SystemNavigator.pop(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
