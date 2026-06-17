import 'package:flutter/material.dart';
import '../pages/form_page.dart';
import '../models/book_model.dart';
import '../mongodb/mongo_service.dart';

class DetailPage extends StatelessWidget {
  final Book book;
  const DetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      // Cambiamos el Padding por un SingleChildScrollView por si la descripción es larga
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.coverUrl != null) 
              Center(child: Image.network(book.coverUrl!, height: 220, fit: BoxFit.cover)),
            const SizedBox(height: 20),
            
            Text('Título: ${book.title}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Autor: ${book.author}', style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
            const SizedBox(height: 6),
            
            // ====== NUEVOS CAMPOS A MOSTRAR ======
            Text('Año de Publicación: ${book.publishYear ?? "No registrado"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Número de Páginas: ${book.pageCount ?? "No registrado"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            
            const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              book.description ?? 'Sin descripción disponible.', 
              style: const TextStyle(fontSize: 16, height: 1.3),
              textAlign: TextAlign.justify,
            ),
            // =====================================

            if (book.openLibraryKey != null) ...[
              const SizedBox(height: 12),
              Text('Key API: ${book.openLibraryKey}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
            
            const SizedBox(height: 40), // Espacio firme antes de los botones
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () {
                    // Ten en cuenta si tu FormPage espera "book" o "bookToEdit" según lo creaste
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => FormPage(bookToEdit: book)) // O bookToEdit: book
                    ).then((_) => Navigator.pop(context));
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (book.id != null) {
                      await MongoService.deleteBook(book.id!);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}