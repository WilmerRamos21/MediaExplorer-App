import 'package:flutter/material.dart';
import '../mongodb/mongo_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: FutureBuilder<int>(
        future: MongoService.getCount(),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Center(
            child: Text('Libros totales almacenados en Local: $count', style: const TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Integrante:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('- Wilmer Ramos\n'),
            Text('API Utilizada:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('- Open Library Search API\n'),
            Text('Explicación Técnica:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('App móvil construida en Flutter que implementa peticiones HTTP asíncronas para el consumo de APIs REST, CRUD y conexiones directas TCP/TLS mediante el driver mongo_dart para gestionar la persistencia en la nube con MongoDB Atlas.'),
          ],
        ),
      ),
    );
  }
}