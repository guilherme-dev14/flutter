import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/models/book.dart';

const String _placeholderImage =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

bool _isValidBase64(String? str) {
  if (str == null || str.isEmpty) return false;
  try {
    base64Decode(str);
    return true;
  } catch (_) {
    return false;
  }
}
class BookCard extends StatelessWidget {
  final BookModel book;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onToggleAvailable;

  const BookCard({
    super.key,
    required this.book,
    required this.isAdmin,
    required this.onTap,
    this.onToggleAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.memory(
  base64Decode(
    _isValidBase64(book.cover)
        ? book.cover
        : _placeholderImage,
  ),
  width: 50,
  height: 50,
  fit: BoxFit.cover,
),
        title: Text(book.title),
        subtitle: Text(book.author),
        trailing: Switch(
          value: book.available,
          onChanged: (_) => onToggleAvailable?.call(),
        ),
        onTap: onTap,
      ),
    );
  }
}
