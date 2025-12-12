import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.quantity,
    required super.unit,
    required super.expiryDate,
    required super.addedDate,
    super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'],
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${json['category']}',
      ),
      quantity: json['quantity'],
      unit: json['unit'],
      expiryDate: DateTime.parse(json['expiry_date']),
      addedDate: DateTime.parse(json['added_date']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toString().split('.').last,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate.toIso8601String(),
      'added_date': addedDate.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      category: product.category,
      quantity: product.quantity,
      unit: product.unit,
      expiryDate: product.expiryDate,
      addedDate: product.addedDate,
      imageUrl: product.imageUrl,
    );
  }
}