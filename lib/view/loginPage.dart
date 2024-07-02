import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../utilis/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _showPassword = false;

  final _auth = FirebaseAuth.instance;

  void login() async {
    if (_username.isNotEmpty && _password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: _username, password: _password);
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        final firstName = userDoc.data()!['firstName'];
        utils().toastMessage(firstName.toString());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
      } catch (error) {
        debugPrint(error.toString());
        utils().toastMessage(error.toString());
      }
    } else {
      utils().toastMessage('Please enter your username and password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Color.fromARGB(255, 15, 73, 189),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.0, right: 45, left: 45),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please Login',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username or Email',
                  labelStyle:
                      TextStyle(color: Colors.blue), // Change the label color
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width:
                            2), // Change the border color and width when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 88, 57, 161),
                      width: 3.0,
                    ), // Change the border color and width
                  ),
                  // Add other attributes as needed, such as prefixIcon, suffixIcon, hintText, etc.
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: Colors.blue), // Change the label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 114, 89, 174),
                      width: 3.0,
                    ), // Change the border color and width when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 114, 89, 174),
                        width: 3.0), // Change the border color and width
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  } else {
                    String pattern =
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                    RegExp regExp = RegExp(pattern);
                    if (!regExp.hasMatch(value)) {
                      return 'Incorrect Password format';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    login();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 119, 183, 217), backgroundColor: Color.fromARGB(255, 9, 9, 184), minimumSize: Size(112, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: Color.fromARGB(255, 30, 13, 181),
                        width: 2), // Add border side
                  ),
                  elevation: 3, // Add elevation/shadow
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Change the text color
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 100, 22, 210),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
