import 'package:flutter/material.dart';
import '../pages/collection_page.dart';
import '../pages/api_explorer_page.dart';
import '../pages/about_page.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Manager App')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(context, 'Colección Local', Icons.storage, const CollectionPage()),
          _menuCard(context, 'Explorar API', Icons.language, const ApiExplorerPage()),
          _menuCard(context, 'Acerca de la APP', Icons.analytics, const AboutPage()),
        ],
      ),
    );
  }

  Widget _menuCard(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}