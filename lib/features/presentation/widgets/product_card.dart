import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Emoji иконка
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  product.imageUrl ?? '📦',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Информация о продукте
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.quantity} ${product.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getExpiryText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Кнопка удаления
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (product.isExpired) return Colors.red;
    if (product.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  Color _getBackgroundColor() {
    if (product.isExpired) return Colors.red.shade50;
    if (product.isExpiringSoon) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Color _getStatusColor() {
    if (product.isExpired) return Colors.red;
    if (product.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (product.isExpired) return Icons.error;
    if (product.isExpiringSoon) return Icons.warning;
    return Icons.check_circle;
  }

  String _getExpiryText() {
    if (product.isExpired) {
      final daysExpired = DateTime.now().difference(product.expiryDate).inDays;
      return 'Просрочено $daysExpired дн. назад';
    }
    
    final daysLeft = product.expiryDate.difference(DateTime.now()).inDays;
    
    if (product.isExpiringSoon) {
      return 'Осталось $daysLeft дн.';
    }
    
    return 'Свежий ($daysLeft дн.)';
  }
}