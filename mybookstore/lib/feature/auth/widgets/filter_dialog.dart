// lib/feature/admin/widgets/filter_dialog.dart
import 'package:flutter/material.dart';

class FilterOptions {
  String? author;
  int? yearStart;
  int? yearFinish;
  int? rating;
  bool? available;
  
  FilterOptions({
    this.author,
    this.yearStart,
    this.yearFinish,
    this.rating,
    this.available,
  });
}

class FilterDialog extends StatefulWidget {
  final FilterOptions initialOptions;
  final Function(FilterOptions) onApply;
  
  const FilterDialog({
    Key? key,
    required this.initialOptions,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _authorController;
  late TextEditingController _yearStartController;
  late TextEditingController _yearFinishController;
  late int _rating;
  late bool _available;

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController(text: widget.initialOptions.author ?? '');
    _yearStartController = TextEditingController(
        text: widget.initialOptions.yearStart?.toString() ?? '');
    _yearFinishController = TextEditingController(
        text: widget.initialOptions.yearFinish?.toString() ?? '');
    _rating = widget.initialOptions.rating ?? 0;
    _available = widget.initialOptions.available ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar busca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text('Filtrar por autor'),
            const SizedBox(height: 8),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                hintText: 'Nome do autor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text('Filtrar por ano'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearStartController,
                    decoration: InputDecoration(
                      hintText: 'Ano inicial',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _yearFinishController,
                    decoration: InputDecoration(
                      hintText: 'Ano final',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            const Text('Filtrar por classificação'),
            const SizedBox(height: 8),
            Slider(
              value: _rating.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating == 0 ? 'Todos' : _rating.toString(),
              activeColor: const Color(0xFF610BEF),
              onChanged: (value) {
                setState(() {
                  _rating = value.toInt();
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Text('Apenas disponíveis'),
                const Spacer(),
                Switch(
                  value: _available,
                  activeColor: const Color(0xFF610BEF),
                  onChanged: (value) {
                    setState(() {
                      _available = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF610BEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Criar o objeto de filtros
                    final options = FilterOptions(
                      author: _authorController.text.isEmpty ? null : _authorController.text,
                      yearStart: _yearStartController.text.isEmpty
                          ? null
                          : int.tryParse(_yearStartController.text),
                      yearFinish: _yearFinishController.text.isEmpty
                          ? null
                          : int.tryParse(_yearFinishController.text),
                      rating: _rating == 0 ? null : _rating,
                      available: _available,
                    );
                    
                    // Chamar o callback
                    widget.onApply(options);
                    
                    // Fechar o diálogo
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authorController.dispose();
    _yearStartController.dispose();
    _yearFinishController.dispose();
    super.dispose();
  }
}