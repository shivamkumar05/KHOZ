import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chaleno/chaleno.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../main.dart';

class ScrapPage extends StatefulWidget {
  @override
  _ScrapPage createState() => _ScrapPage();
}

class _ScrapPage extends State<ScrapPage> {
  final _searchController = TextEditingController();
  // String? _websiteUrl;
  List<String> _urls = [];
  int _currentPage = 1;
  int _resultsPerPage = 10;
  List<String> _searchHistory = [];
  List<String> _visitedURLs = [];
  Map<String, List<String>> _cachedData = {};

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadVisitedURLs();
    _loadCachedData(); // Load the cached data
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scrapData(String url) async {
    if (!url.startsWith('https://')) {
      url = 'https://' + url;
    }

    // if (hasDomainSuffix(url) == false) {
    //   checkAndUpdateTextField(url) as String;
    //   url = _searchController.text;
    // }

    var response = await attemptFirestoreOperation(() {
      return Chaleno().load(url);
    });

    if (response != null) {
      List<Result>? results = response.getElementsByTagName('a');
      var n = results!.length;
      List<String> urls = [];
      for (var i = 0; i < n; i++) {
        String href = results[i].attr('href') ?? '';
        if (href.startsWith('https://')) {
          urls.add(href);
        }
      }

      setState(() {
        _urls = urls;
        _currentPage = 1; // Reset page number
      });
    } else {
      // Handle the case where the Firestore operation failed
      // You can display an error message or take appropriate action
      print('Firebase operation failed');
    }
  }

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _text = '';
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        // ignore: avoid_print
        onStatus: (val) => print('onStatus: $val'),
        // ignore: avoid_print
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords.toLowerCase();
              _searchController.text = _text;
            });
          },
          listenFor: const Duration(seconds: 5),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   super.dispose();
  // }

  Future<T?> attemptFirestoreOperation<T>(
      Future<T> Function() operation) async {
    const int maxRetries = 3;
    const Duration initialDelay = Duration(seconds: 1);

    for (var i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        print('Firestore operation failed: $e');
        await Future.delayed(initialDelay * (i + 1));
      }
    }

    return null; // Operation failed after maximum retries
  }

  void _saveSearchQuery(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedHistory = [..._searchHistory];
    updatedHistory.add(query);
    await prefs.setStringList('searchHistory', updatedHistory);
    setState(() {
      _searchHistory = updatedHistory;
    });
    await _saveCachedData(); // Save the cached data
  }

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedData = prefs.getStringList('cachedData');
    if (cachedData != null) {
      setState(() {
        _cachedData = cachedData.fold<Map<String, List<String>>>({},
            (Map<String, List<String>> map, String entry) {
          final parts = entry.split(':');
          final url = parts[0];
          final urls = parts[1].split(',');
          map[url] = urls;
          return map;
        });
      });
    }
  }

  Future<void> _saveCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'cachedData',
      _cachedData.entries.map((entry) {
        return '${entry.key}:${entry.value.join(',')}';
      }).toList(),
    );
  }

  void _clearCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cachedData');
    setState(() {
      _cachedData = {};
    });
  }

  void _launchURL(String url, String uid) async {
    setState(() {
      _visitedURLs.add(url);
    });
    addSearchQueryToFirestore(uid, url);
    await _saveVisitedURLs(); // Save visited URLs
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage(url)),
    ).then((_) {
      _loadVisitedURLs(); // Reload visited URLs after returning from WebViewPage
    });
  }

  String _stripHtmlTags(String html) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return html.replaceAll(exp, '');
  }

  List<String> _getCurrentPageUrls() {
    final startIndex = (_currentPage - 1) * _resultsPerPage;
    final endIndex = startIndex + _resultsPerPage;
    if (startIndex >= _urls.length) {
      return []; // Return empty list if start index is out of range
    }
    return _urls.sublist(startIndex, endIndex.clamp(0, _urls.length));
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  void _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory = [];
    });
  }

  Future<void> _loadVisitedURLs() async {}

  Future<void> _saveVisitedURLs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('visitedURLs', _visitedURLs);
  }

  void _clearVisitedURLs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('visitedURLs');
    setState(() {
      _visitedURLs = [];
    });
  }

  Future<String> _getTitle(String url) async {
    var response = await Chaleno().load(url);
    List<Result>? results = response!.getElementsByTagName('title');
    if (results != null && results.isNotEmpty) {
      return results[0].text ?? '';
    }
    return '';
  }

  Future<String> _getDescription(String url) async {
    var response = await Chaleno().load(url);
    List<Result>? results = response!.getElementsByTagName('meta');
    var n = results?.length ?? 0;

    for (var i = 0; i < n; i++) {
      var name = results![i].attr('name');
      if (name != null && name.toLowerCase() == 'description') {
        String description = results[i].attr('content') ?? '';
        return _stripHtmlTags(description);
      }
    }
    return '';
  }

  Future<void> addSearchQueryToFirestore(
      String userId, String searchQuery) async {
    // Get a reference to the user's search history collection
    CollectionReference searchHistoryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history');

    // Create a new document to store the search query data
    DocumentReference searchQueryDoc = searchHistoryCollection.doc();

    // Create a map to store the search query data
    Map<String, dynamic> searchQueryData = {
      'query': searchQuery,
      'timestamp': FieldValue.serverTimestamp(),
      // add current timestamp
    };

    // Add the search query data to the document
    await searchQueryDoc.set(searchQueryData);
  }

  Future<void> checkAndUpdateTextField(String userInput) async {
    // Get a reference to the Firestore collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection('crawlWebsites');
    print("shivam");
//       String cleanedUserInput = userInput.replaceAll('//', '/');
//       Uri uri = Uri.parse(userInput);
// String normalizedUrl = uri.normalizePath().toString();

    // Check if the document with the user input as ID exists
    DocumentSnapshot snapshot = await collection.doc(userInput).get();
    print("shivam2");

    if (snapshot.exists) {
      // Retrieve the 'websiteurl' field from the document
      String websiteUrl = snapshot.get('websiteurl');
      print("shivam3");

      // Update the TextField widget with the website URL
      // Here, we assume that the TextField widget has a TextEditingController named "controller"

      // Update the TextField with the retrieved website URL
      //_searchController.text = websiteUrl;
      _scrapData(websiteUrl);
      // setState(() {
      // });
    } else {
      _scrapData(userInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    // this code old version without login problem
    // final uid = _firebaseAuth.currentUser!.uid;

    //this code also worked
    // final uid = _firebaseAuth.currentUser != null
    //     ? _firebaseAuth.currentUser!.uid
    //     : 'Unknown';

    // this code also worked without login process
    final uid = _firebaseAuth.currentUser?.uid ?? 'Unknown';

    final List<String> currentPageUrls = _getCurrentPageUrls();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
          icon: const Icon(Icons.home),
        ),
        backgroundColor: Color.fromARGB(255, 23, 86, 214),
        title: GestureDetector(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  child: const Icon(
                    Icons.search,
                    color: Colors.blueAccent,
                  ),
                  margin: const EdgeInsets.fromLTRB(3, 0, 7, 0),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    checkAndUpdateTextField(_searchController.text);
                    _scrapData(_searchController.text);

                    // value store input of searchBar
                    // _scrapData(controller);
                    // print("hello");
                  },
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Search Here"),
                ),
              ),
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic),
                onPressed: _listen,
              ),
            ],
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.history),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => SearchHistoryPage(_searchHistory),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currentPageUrls.length,
              itemBuilder: (context, index) {
                final url = currentPageUrls[index];
                final bool isVisited = _visitedURLs.contains(url);
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
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 450,
                          height: 90,
                          child: ListTile(
                            title: Text(
                              url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: FutureBuilder<String>(
                              future: _getDescription(url),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  String description = snapshot.data!;
                                  if (description.length > 150) {
                                    description =
                                        description.substring(0, 150) + '...';
                                  }
                                  return Text(description);
                                } else {
                                  return Text('Loading...');
                                }
                              },
                            ),
                            onTap: () {
                              _launchURL(_urls[index], uid);
                              if (!isVisited) {
                                _visitedURLs.add(url);
                                _saveVisitedURLs();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _currentPage > 1
                    ? () {
                        _goToPage(_currentPage - 1);
                      }
                    : null,
              ),
              Text('Page $_currentPage'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: (_currentPage * _resultsPerPage) < _urls.length
                    ? () {
                        _goToPage(_currentPage + 1);
                      }
                    : null,
              ),
            ],
          ),
        ],
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
