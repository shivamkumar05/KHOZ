import 'package:http/http.dart' as http;
import 'dart:convert';

final String apiUrl = 'https://your-api-endpoint.com/search';

Future<List<dynamic>> search(String query) async {
  final response = await http.post(apiUrl as Uri, body: {'query': query});

  if (response.statusCode == 200) {
    final List<dynamic> results = json.decode(response.body);
    return results;
  } else {
    throw Exception('Failed to load search results');
  }
}
