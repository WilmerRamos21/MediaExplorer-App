import 'package:flutter/material.dart';
import '../pages/detail_page.dart';
import '../pages/form_page.dart';

import '../models/book_model.dart';
import '../mongodb/mongo_service.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final List<Book> _localBooks = [];
  final ScrollController _scrollController = ScrollController();
  int _skip = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMoreBooks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreBooks();
      }
    });
  }

  Future<void> _loadMoreBooks() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newBooks = await MongoService.getLocalBooks(limit: 10, skip: _skip);
    setState(() {
      _isLoading = false;
      if (newBooks.length < 10) _hasMore = false;
      _skip += newBooks.length;
      _localBooks.addAll(newBooks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Colección Local')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPage())).then((_) {
          // Resetear y recargar al volver
          setState(() { _localBooks.clear(); _skip = 0; _hasMore = true; });
          _loadMoreBooks();
        }),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _localBooks.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _localBooks.length) return const Center(child: CircularProgressIndicator());
          final book = _localBooks[index];
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(book: book))).then((_) {
              setState(() { _localBooks.clear(); _skip = 0; _hasMore = true; });
              _loadMoreBooks();
            }),
          );
        },
      ),
    );
  }
}