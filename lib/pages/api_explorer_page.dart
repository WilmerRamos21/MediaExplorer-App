import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';


import '../models/book_model.dart';
import '../mongodb/mongo_service.dart';

class ApiExplorerPage extends StatefulWidget {
  const ApiExplorerPage({super.key});
  @override
  State<ApiExplorerPage> createState() => _ApiExplorerPageState();
}

class _ApiExplorerPageState extends State<ApiExplorerPage> {
  final List<Book> _apiBooks = [];
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  final translator = GoogleTranslator();

  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchApiData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchApiData();
      }
    });
  }

  Future<void> _fetchApiData() async {
    if (_isLoading) return;

    // Capturar lo que el usuario escribe, si esta vacio que use un valor pordefecto
    String currentQuery = _searchController.text.trim();
    if (currentQuery.isEmpty){
      currentQuery = 'novelas';
    }
    
    if(!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Usar la variable dinamica de la URL de la API
      final url = Uri.parse('https://openLibrary.org/search.json?q=$currentQuery&page=$_page');

      final response = await http.get(url);

      if (response.statusCode == 200){
        // Decodificar el JSON que responde OpenLibrary
        final data = jsonDecode(response.body);
        final List docs =data['docs'] ?? [];
        
        // Convertir cada mapa de JSON en un objeto Book nativo adaptando las llaves de Open Library
        final List<Book> newBooks = docs.map((bookMap) {
          // 1. Open Library devuelve los autores en una lista llamada 'author_name'
          final List? authorList = bookMap['author_name'];
          final String parsedAuthor = (authorList != null && authorList.isNotEmpty) 
              ? authorList.first.toString() 
              : 'Autor Desconocido';

          // 2. Open Library devuelve un ID numérico en 'cover_i'. Hay que armar la URL real.
          String? parsedCoverUrl;
          if (bookMap['cover_i'] != null) {
            parsedCoverUrl = 'https://covers.openlibrary.org/b/id/${bookMap['cover_i']}-M.jpg';
          }

          // -- Nuevas extracciones de la APi
          // OpenLibrary suele devolver la fecha en 'first_publish_year' y paginas 'number_of_pages_median'
          final String? parsedYear = bookMap['first_publish_year']?.toString();
          final int? parsedPages = bookMap['number_of_pages_median'];

          // 3. Retornamos el libro construido con los datos que tu modelo sí entiende
          return Book(
            id: null, // Es un libro de la API, aún no tiene ID de MongoDB
            title: bookMap['title'] ?? 'Sin Título',
            author: parsedAuthor,
            coverUrl: parsedCoverUrl,
            openLibraryKey: bookMap['key'] ?? '',
            publishYear: parsedYear,
            description: null,
            pageCount: parsedPages,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _page++;
            _apiBooks.addAll(newBooks); // Aquí metemos los libros nuevos a la lista que dibuja la pantalla
          });
        }
      }

    } catch (e) {
      setState(() => _isLoading = false);
    } finally{
      if(mounted) setState(() => _isLoading = false);
    }
  }
    Future<Map<String, dynamic>> _fetchBookDetails(String workKey) async{
    try{
      final url = Uri.parse('https://openlibrary.org$workKey.json');

      final response = await http.get(url);
          if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      String? description;

      if (data['description'] is String) {

        description = data['description'];

      } else if (data['description'] is Map) {

        description = data['description']['value'];

      }

      return {

        'description': description,

      };

    }
    }catch(e){(e);}
    return {};
  }
  Future<String?> _translateDescription(String? text) async {
  if (text == null || text.isEmpty) return null;

  try {
    final translation = await translator.translate(
      text,
      from: 'en',
      to: 'es',
    );

    return translation.text;
  } catch (e) {
    (e);
    return text; // devuelve la original si falla
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Open Library')),
      body: Column(
        children: [
          // Añadimos la barra de búsqueda arriba de la lista
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar (ej: historia, ciencia ficcion, novelas)...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) {
                      _apiBooks.clear();
                      _page = 1;
                      _fetchApiData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _apiBooks.clear();
                    _page = 1;
                    _fetchApiData();
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          
          // La lista ahora va dentro de un Expanded para que no choque con el buscador
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _apiBooks.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _apiBooks.length) return const Center(child: CircularProgressIndicator());
                final book = _apiBooks[index];
                return ListTile(
                  leading: book.coverUrl != null 
                      ? Image.network(
                          book.coverUrl!, 
                          width: 50, 
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.book), // Por si falla la carga de la imagen
                        ) 
                      : const Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_add, color: Colors.green),
                    onPressed: () async {
                      String? description;

                      if (book.openLibraryKey != null) {

                        final details =
                            await _fetchBookDetails(book.openLibraryKey!);
                        // Descripción original (inglés)
                        description = details['description'];
                        // Traducción al español
                        description = await _translateDescription(description);
                      }

                      final completeBook = Book(
                        title: book.title,
                        author: book.author,
                        coverUrl: book.coverUrl,
                        openLibraryKey: book.openLibraryKey,
                        publishYear: book.publishYear,
                        pageCount: book.pageCount,
                        description: description,
                      );

                      await MongoService.insertBook(completeBook);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${book.title}" guardado correctamente'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}