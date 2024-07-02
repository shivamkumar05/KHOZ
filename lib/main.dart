import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'view/profilePage.dart';
import 'view/settingPage.dart';
import 'package:provider/provider.dart';
import 'view/Helpfeedback.dart';
import 'package:flutter/material.dart';
import 'News/news_home.dart';
import 'view/home.dart';
import 'view/loginPage.dart';
import 'view/download.dart';
import 'view/history.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'view/themepage.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // title: 'My App',
            theme: themeProvider.themeData,
            home: SearchPage(),
          );
        },
      ),
    );
  }
}

String firstNameLetter = FirebaseAuth.instance.currentUser!.displayName![0];

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoggedIn = false;

  String? _firstNameLetter;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final firstName = userDoc.data()?['firstName'];
      setState(() {
        _firstNameLetter = firstName?[0];
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
          icon: const Icon(
            Icons.home,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        // title: const Text('KHOZ SEARCH ENGINE'),
        backgroundColor: const Color.fromARGB(255, 63, 33, 187),

        elevation: 1.0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: _isLoggedIn
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _firstNameLetter ?? '',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              } else if (result == 'Downloads') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DownloadOptionsPage()),
                );
              } else if (result == 'History') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPages()),
                );
              } else if (result == 'Help & feedback') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                );
              } else if (result == 'New tab') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScrapPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'New tab',
                child: ListTile(
                  leading: Icon(Icons.new_label),
                  title: Text('New tab'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'History',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('History'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Downloads',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Downloads'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Desktop site',
                child: ListTile(
                  leading: Icon(Icons.desktop_mac),
                  title: Text('Desktop site'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Help & feedback',
                child: ListTile(
                  leading: Icon(Icons.help_center),
                  title: Text('Help & feedback'),
                ),
              ),
              // const PopupMenuItem<String>(
              //   value: 'Logout',
              //   child: ListTile(
              //     leading: Icon(Icons.logout),
              //     title: Text('Logout'),
              //   ),
              // ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850] // Set the background color for dark theme
            : Colors.white, // Set the background color for light theme
        child: Column(
          children: [
            SizedBox(
              height: 35,
            ),
            MediaQuery(
              data: MediaQuery.of(context),
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/photo_dark.png'
                    : 'assets/images/photo_light.png',
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width *
                    0.70, // set the width based on screen size
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.1, // set height to 62% of screen height
              width: MediaQuery.of(context).size.width *
                  0.9, // set width to 100% of screen width
              child: Flexible(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: const TextSelectionThemeData(
                      selectionColor: Colors.black,
                      cursorColor: Colors.black,
                      selectionHandleColor: Colors.black,
                    ),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors
                                  .white // Customize the border color for dark theme
                              : Colors
                                  .black, // Customize the border color for light theme
                          width: 50.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                      hintText: "Search for web, apps, and more...",
                      prefixIcon: const Icon(Icons.search,
                          color: Color.fromARGB(255, 18, 32, 193)),
                    ),
                    onTap: (() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ScrapPage()),
                      );
                    }),
                    onSubmitted: (value) {},
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.60,
              width: MediaQuery.of(context).size.width * 1,
              child: const Home(),
            ),
          ],
        ),
      ),
    );
  }
}
