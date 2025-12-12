import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart';

class FridgePage extends ConsumerWidget {
  const FridgePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧊 Мой Холодильник',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(productsProvider.notifier).loadProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по категориям
          _buildCategoryFilter(ref, selectedCategory),
          
          // Статистика
          _buildStats(productsAsync),
          
          // Список продуктов
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(productsProvider.notifier).loadProducts();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: products[index],
                        onDelete: () {
                          _showDeleteDialog(
                            context,
                            ref,
                            products[index],
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки данных',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(productsProvider.notifier).loadProducts();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, ProductCategory? selectedCategory) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(
            ref,
            null,
            'Все',
            '📦',
            selectedCategory == null,
          ),
          ...ProductCategory.values.map((category) {
            return _buildCategoryChip(
              ref,
              category,
              _getCategoryName(category),
              _getCategoryIcon(category),
              selectedCategory == category,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    WidgetRef ref,
    ProductCategory? category,
    String label,
    String icon,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(selectedCategoryProvider.notifier).state = 
              selected ? category : null;
        },
        selectedColor: Colors.blue.shade100,
      ),
    );
  }

  Widget _buildStats(AsyncValue<List<Product>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        final expiredCount = products.where((p) => p.isExpired).length;
        final expiringSoonCount = products.where((p) => p.isExpiringSoon).length;
        final totalCount = products.length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Всего', totalCount.toString(), Colors.blue),
              _buildStatItem('Скоро', expiringSoonCount.toString(), Colors.orange),
              _buildStatItem('Просрочено', expiredCount.toString(), Colors.red),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.kitchen_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Холодильник пуст',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте первый продукт',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт?'),
        content: Text('Вы уверены, что хотите удалить "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(productsProvider.notifier).removeProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} удален')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
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

  String _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.dairy:
        return '🥛';
      case ProductCategory.meat:
        return '🍖';
      case ProductCategory.vegetables:
        return '🥕';
      case ProductCategory.fruits:
        return '🍎';
      case ProductCategory.drinks:
        return '🧃';
      case ProductCategory.other:
        return '📦';
    }
  }
}