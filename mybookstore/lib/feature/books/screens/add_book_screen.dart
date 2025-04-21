import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/book.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/auth_repository.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  DateTime? _publishDate;
  int _rating = 0;
  bool _available = true;
  File? _coverImage;
  String? _base64Cover;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() {
        _coverImage = File(picked.path);
        _base64Cover = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty || _publishDate == null || _base64Cover == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios e selecione uma imagem.')),
      );
      return;
    }

    final storeId = await AuthRepository().getCurrentStoreId();
    final book = BookModel(
      cover: _base64Cover!,
      title: _titleController.text,
      author: _authorController.text,
      synopsis: _synopsisController.text,
      year: _publishDate!.year,
      rating: _rating,
      available: _available,
    );

    await BookRepository().addBook(storeId!, book);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar livro'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dados do livro'),
            Tab(text: 'Design do Livro'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInput('Título', _titleController),
                  const SizedBox(height: 16),
                  _buildInput('Autor', _authorController),
                  const SizedBox(height: 16),
                  _buildInput('Sinopse', _synopsisController, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildRatingSelector(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Estoque'),
                    value: _available,
                    onChanged: (val) => setState(() => _available = val),
                    activeColor: const Color(0xFF610BEF),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _base64Cover != null
                    ? Image.memory(base64Decode(_base64Cover!), height: 160)
                    : Container(
                        width: 124,
                        height: 176,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 48),
                      ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('Selecione a imagem de capa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF610BEF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF610BEF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2F2F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1800),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _publishDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _publishDate == null ? 'Ano de publicação' : '${_publishDate!.day}/${_publishDate!.month}/${_publishDate!.year}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            _rating > index ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => setState(() => _rating = index + 1),
        );
      }),
    );
  }
}
