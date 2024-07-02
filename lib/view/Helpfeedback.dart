import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackForm {
  String name;
  String email;
  String message;

  FeedbackForm(
      {required this.name, required this.email, required this.message});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'message': message,
    };
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  void sendFeedback(FeedbackForm feedback) async {
    // Create a reference to the "feedback" child node
    DatabaseReference feedbackRef =
        // ignore: deprecated_member_use
        FirebaseDatabase.instance.reference().child("feedback");

    // Send the feedback data to the database
    await feedbackRef.push().set(feedback.toJson());

    // Log feedback event with Firebase Analytics
    await FirebaseAnalytics.instance.logEvent(
      name: 'user_feedback',
      parameters: {
        'name': feedback.name,
        'email': feedback.email,
        'message': feedback.message,
      },
    );
  }

  void _sendFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      final feedback = FeedbackForm(
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
      );

      DatabaseReference feedbackRef =
          // ignore: deprecated_member_use
          FirebaseDatabase.instance.reference().child("feedback");
      feedbackRef.push().set(feedback.toJson()).then((value) {
        setState(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent')),
        );

        // Clear form fields
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      }).catchError((onError) {
        setState(() {
          _isSending = false;
        });
        print(onError.toString()); // print error message to console
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send feedback')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 84, 218),
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your feedback message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isSending ? null : _sendFeedback,
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(
                        255, 255, 0, 0) // set the text color to white
                    ),
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
