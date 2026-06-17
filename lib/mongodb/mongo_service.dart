import 'package:mongo_dart/mongo_dart.dart';
import '../models/book_model.dart';


class MongoService{
  static const String _connectionString = 'mongodb+srv://user26am:12345@cluster0.q2g1udw.mongodb.net/';
  static const String _collectionName = 'books';
  static Db? _db;
  static DbCollection? _collection;


  static Future<void> connect() async {
    if (_db != null) return ;

    try{
      _db = await Db.create(_connectionString);
      await _db!.open();
      _collection = _db!.collection(_collectionName);

    }catch(e){
      e;
    }
  } 
  static Future<List<Book>> getLocalBooks({int limit = 10, int skip = 0}) async{
    if(_collection == null) await connect();

    final booksData = await _collection!.find(SelectorBuilder().limit(limit).skip(skip)).toList();
    return booksData.map((map) => Book.fromMap(map)).toList();
  }
  static Future<void> insertBook(Book book) async {
    if (_collection == null) await connect();
    await _collection!.insertOne(book.toMap());
  }

  static Future<void> updateBook(Book book) async {
    if (_collection == null) await connect();
    final id = ObjectId.fromHexString(book.id!);
    await _collection!.updateOne(where.id(id), modify.set('title', book.title).set('author', book.author));
  }

  static Future<void> deleteBook(String id) async {
    if (_collection == null) await connect();
    final objId = ObjectId.fromHexString(id);
    await _collection!.deleteOne(where.id(objId));
  }

  static Future<int> getCount() async {
    if (_collection == null) await connect();
    return await _collection!.count();
  }
}