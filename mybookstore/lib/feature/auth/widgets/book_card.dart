// lib/feature/admin/widgets/book_card.dart
import 'package:flutter/material.dart';
import 'package:mybookstore/data/models/book.dart';
import 'package:cached_network_image.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  
  const BookCard({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: CachedNetworkImage(
                  imageUrl: book.cover,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            
            // Book info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < book.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}