import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class ApiService {
  static Future<List<Book>> searchBooks(String query, int page) async {
    final url = Uri.parse('https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List docs = data['docs'] ?? [];
      return docs.map((doc) => Book.fromMap(doc)).toList();
    } else {
      throw Exception('Error al cargar libros de Open Library');
    }
  }
}