import 'package:equatable/equatable.dart';

enum ProductCategory {
  dairy,      // Молочные
  meat,       // Мясо
  vegetables, // Овощи
  fruits,     // Фрукты
  drinks,     // Напитки
  other,      // Другое
}

class Product extends Equatable {
  final String id;
  final String name;
  final ProductCategory category;
  final int quantity;
  final String unit; // шт, кг, л
  final DateTime expiryDate;
  final DateTime addedDate;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.addedDate,
    this.imageUrl,
  });

  bool get isExpiringSoon {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  @override
  List<Object?> get props => [id, name, category, quantity, unit, expiryDate, addedDate, imageUrl];
}
