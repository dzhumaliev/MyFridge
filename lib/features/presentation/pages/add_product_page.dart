import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  
  ProductCategory _selectedCategory = ProductCategory.other;
  String _selectedUnit = 'шт';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  String _selectedEmoji = '📦';

  final List<String> _units = ['шт', 'кг', 'г', 'л', 'мл'];
  
  final Map<ProductCategory, List<String>> _categoryEmojis = {
    ProductCategory.dairy: ['🥛', '🧀', '🧈', '🥚', '🍦'],
    ProductCategory.meat: ['🍖', '🍗', '🥩', '🍤', '🐟'],
    ProductCategory.vegetables: ['🥕', '🍅', '🥒', '🥬', '🌽'],
    ProductCategory.fruits: ['🍎', '🍊', '🍌', '🍇', '🍓'],
    ProductCategory.drinks: ['🧃', '🥤', '🍷', '☕', '🧋'],
    ProductCategory.other: ['📦', '🍞', '🍰', '🍫', '🍪'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить продукт'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Emoji selector
            Center(
              child: GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Название
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название продукта',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Категория
            DropdownButtonFormField<ProductCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ProductCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedEmoji = _categoryEmojis[value]![0];
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Количество и единица измерения
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Количество',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите количество';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Только цифры';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Ед.',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Срок годности
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Срок годности'),
              subtitle: Text(
                '${_expiryDate.day}.${_expiryDate.month}.${_expiryDate.year}',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectExpiryDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 32),

            // Кнопка добавить
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Добавить в холодильник',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите иконку',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _categoryEmojis[_selectedCategory]!.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _selectedEmoji == emoji
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        category: _selectedCategory,
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        addedDate: DateTime.now(),
        imageUrl: _selectedEmoji,
      );

      ref.read(productsProvider.notifier).addNewProduct(product);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} добавлен в холодильник')),
      );
    }
  }

  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.dairy:
        return 'Молочное';
      case ProductCategory.meat:
        return 'Мясо';
      case ProductCategory.vegetables:
        return 'Овощи';
      case ProductCategory.fruits:
        return 'Фрукты';
      case ProductCategory.drinks:
        return 'Напитки';
      case ProductCategory.other:
        return 'Другое';
    }
  }
}