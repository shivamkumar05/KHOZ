import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginPage.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _password = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showPassword1 = false;

  void _registerUser() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _username,
        password: _password,
      );

      // User registration successful
      String uid = userCredential.user!.uid;

      // Add first name, last name, and email to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _username,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SearchPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {}
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
        backgroundColor: Color.fromARGB(255, 18, 84, 218),
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
                'Create a New Account',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(
                      color: Colors.blue), // Change the label color
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ), // Change the border color and width when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 114, 89, 174),
                      width: 3.0,
                    ), // Change the border color and width
                  ),
                  // Add other attributes as needed, such as prefixIcon, suffixIcon, hintText, etc.
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle:
                      TextStyle(color: Colors.blue), // Change the label color
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Colors.blue,
                        width:
                            2), // Change the border color and width when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 114, 89, 174),
                        width: 3.0), // Change the border color and width
                  ),
                  // Add other attributes as needed, such as prefixIcon, suffixIcon, hintText, etc.
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Colors.blue), // Change the label color
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Colors.blue,
                        width:
                            2), // Change the border color and width when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 114, 89, 174),
                        width: 3.0), // Change the border color and width
                  ),
                  // Add other attributes as needed, such as prefixIcon, suffixIcon, hintText, etc.
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Colors.blue,
                        width:
                            2), // Change the border color and width when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 114, 89, 174),
                        width: 3.0), // Change the border color and width
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword1 ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blue, // Change the icon color
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword1 = !_showPassword1;
                      });
                    },
                  ),
                  // Add other attributes as needed, such as prefixIcon, hintText, etc.
                ),
                obscureText: !_showPassword1,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  String pattern =
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                  RegExp regExp = RegExp(pattern);
                  if (!regExp.hasMatch(value)) {
                    return 'Password is weak';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _registerUser();
                  }
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Change the text color
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 119, 183,
                      217), backgroundColor: Color.fromARGB(255, 9, 9, 184), minimumSize: Size(112, 45), // Change the text color when button is pressed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: Color.fromARGB(255, 30, 13, 181),
                        width: 2), // Add border side
                  ),
                  elevation: 5, // Add elevation/shadow
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have Account ?',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'login',
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
