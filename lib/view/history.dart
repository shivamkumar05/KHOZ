import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';


class HistoryPages extends StatefulWidget {
  @override
  _HistoryPagesState createState() => _HistoryPagesState();
}

class _HistoryPagesState extends State<HistoryPages> {
  Future<List<String>> getSearchHistoryQueries(String userId) async {
    List<String> queries = [];
    CollectionReference searchHistoryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history');

    QuerySnapshot searchHistorySnapshot = await searchHistoryCollection
        .orderBy('timestamp', descending: true)
        .get();

    searchHistorySnapshot.docs.forEach((doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('query')) {
        String query = data['query'];
        queries.add(query);
      }
    });

    return queries;
  }

  Future<void> _deleteSearchHistory(String userId, String query) async {
    CollectionReference searchHistoryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history');

    QuerySnapshot searchHistorySnapshot =
        await searchHistoryCollection.where('query', isEqualTo: query).get();

    searchHistorySnapshot.docs.forEach((doc) async {
      await doc.reference.delete();
    });

    setState(() {}); // Trigger rebuild of the widget tree
  }

  void _launchURL(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage(url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 84, 218),
        title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add your search functionality here
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: getSearchHistoryQueries(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> queries = snapshot.data!;
            return ListView.builder(
              itemCount: queries.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: SizedBox(
                          width: 350,
                          height: 52,
                          child: ListTile(
                            title: Text(
                              queries[index],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              _launchURL(context, queries[index]);
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteSearchHistory(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    queries[index]);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(url),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
