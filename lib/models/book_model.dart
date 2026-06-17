
class Book{

  String? id; // ID que se recibe desde mongodb
  final String title;
  final String author;
  final String? coverUrl;
  final String? openLibraryKey;
  
  final String? publishYear;
  final String? description;
  final int? pageCount;

  Book({
    this.id, 
    required this.title,
    required this.author, 
    this.coverUrl, 
    this.openLibraryKey,
    this.publishYear,
    this.description,
    this.pageCount
    
    });

  // Para enviar a MongoDB
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'openLibraryKey': openLibraryKey,
      'publishYear': publishYear,
      'description': description,
      'pageCount': pageCount,
    };
  }

  // Para recibir de MongoDB
  factory Book.fromMap(Map<String, dynamic> map) {
    String? rawId = map['_id']?.toString();
    if (rawId != null && rawId.startsWith('ObjectId("')) {
      rawId = rawId.replaceAll('ObjectId("', '').replaceAll('")', '');
    }

    return Book(
      id: rawId,
      title: map['title'] ?? 'Sin Título',
      author: map['author'] ?? 'Autor Desconocido',
      coverUrl: map['coverUrl'],
      openLibraryKey: map['openLibraryKey'],
      publishYear: map['publishYear']?.toString(), // Aseguramos que sea texto
      description: map['description'],
      // Comprobamos si viene como número o como texto desde Mongo
      pageCount: map['pageCount'] is int ? map['pageCount'] : int.tryParse(map['pageCount']?.toString() ?? ''),
    );
  }

}