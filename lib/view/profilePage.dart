import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color.fromARGB(255, 30, 13, 181),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(_user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              SizedBox(height: 54),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 142, 158, 227),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(13.0),
                    child: Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  data['firstName'][0] + data['lastName'][0],
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 52),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 114, 89, 174),
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Full Name: ${data['firstName']} ${data['lastName']}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 133, 40, 121),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 114, 89, 174),
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Email: ${_user.email}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 114, 89, 174),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 197, 155, 155), backgroundColor: Color.fromARGB(255, 5, 64, 113),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
