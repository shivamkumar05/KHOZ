import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'package:provider/provider.dart';
import 'AboutPage.dart';
import 'themepage.dart';
import 'home.dart';

// settings class
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Define variables to hold the user's preferred settings
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScrapPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  bool isDarkModeEnabled = false;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 84, 218),
        title: const Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Add UI elements for enabling/disabling dark mode
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(themeProvider.isDarkModeEnabled
                    ? 'Light mode'
                    : 'Dark mode'),
                value: themeProvider.isDarkModeEnabled,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),

          // Add UI elements for selecting a language
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
              items: ['English', 'Hindi', 'Spanish', 'French', 'bhojpuri']
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          // Add UI elements for about Khoze and services
          GestureDetector(
            child: const ListTile(
              title: Text('About Khoze'),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Services'),
            onTap: () {
              // Navigate to the Services page
            },
          ),
        ],
      ),
    );
  }
}
