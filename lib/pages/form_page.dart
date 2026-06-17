import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../mongodb/mongo_service.dart';

class FormPage extends StatefulWidget {
  final Book? bookToEdit;
  const FormPage({super.key, this.bookToEdit});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _coverUrlController;
  late TextEditingController _publishYearController;
  late TextEditingController _descriptionController;
  late TextEditingController _pageCountController;

  @override
  void dispose() {
    // Es buena práctica limpiarlos al salir
    _titleController.dispose();
    _authorController.dispose();
    _coverUrlController.dispose();
    _publishYearController.dispose();
    _descriptionController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bookToEdit?.title ?? '');
    _authorController = TextEditingController(text: widget.bookToEdit?.author ?? '');
    _coverUrlController = TextEditingController(text: widget.bookToEdit?.coverUrl ?? '');
    _publishYearController = TextEditingController(text: widget.bookToEdit?.publishYear ?? '');
    _descriptionController = TextEditingController(text: widget.bookToEdit?.description ?? '');
    _pageCountController = TextEditingController(text: widget.bookToEdit?.pageCount?.toString() ?? '');
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: widget.bookToEdit?.id,
        title: _titleController.text,
        author: _authorController.text,
        // Si el texto está vacío, lo enviamos como null
        coverUrl: _coverUrlController.text.isNotEmpty ? _coverUrlController.text : null,
        publishYear: _publishYearController.text.isNotEmpty ? _publishYearController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        pageCount: int.tryParse(_pageCountController.text),
      );

      if (widget.bookToEdit == null) {
        await MongoService.insertBook(book);
      } else {
        await MongoService.updateBook(book);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookToEdit == null ? 'Agregar Libro' : 'Editar Libro')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(labelText: 'URL de la Portada (Opcional)'),
              ),
              TextFormField(
                controller: _publishYearController,
                decoration: const InputDecoration(labelText: 'Año de Publicación (Opcional)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _pageCountController,
                decoration: const InputDecoration(labelText: 'Número de Páginas (Opcional)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                maxLines: 3, // Hace que la caja sea más grande
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveForm, child: const Text('Guardar'))
            ],
          ),
        ),
        ),
      ),
    );
  }
}