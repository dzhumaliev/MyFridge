import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<bool> deleteProduct(String id);
  Future<ProductModel> updateProduct(ProductModel product);
}

// 🎭 MOCK HTTP CLIENT - возвращает тестовые ответы
class MockHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  
  // 📦 Тестовая база данных
  final List<Map<String, dynamic>> _mockDatabase = [
    {
      'id': '1',
      'name': 'Молоко',
      'category': 'dairy',
      'quantity': 2,
      'unit': 'л',
      'expiry_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'added_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'image_url': '🥛',
    },
    {
      'id': '2',
      'name': 'Яйца',
      'category': 'dairy',
      'quantity': 10,
      'unit': 'шт',
      'expiry_date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'added_date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'image_url': '🥚',
    },
    {
      'id': '3',
      'name': 'Помидоры',
      'category': 'vegetables',
      'quantity': 5,
      'unit': 'шт',
      'expiry_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'added_date': DateTime.now().toIso8601String(),
      'image_url': '🍅',
    },
    {
      'id': '4',
      'name': 'Курица',
      'category': 'meat',
      'quantity': 1,
      'unit': 'кг',
      'expiry_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'added_date': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      'image_url': '🍗',
    },
    {
      'id': '5',
      'name': 'Яблоки',
      'category': 'fruits',
      'quantity': 8,
      'unit': 'шт',
      'expiry_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'added_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'image_url': '🍎',
    },
    {
      'id': '6',
      'name': 'Апельсиновый сок',
      'category': 'drinks',
      'quantity': 1,
      'unit': 'л',
      'expiry_date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      'added_date': DateTime.now().toIso8601String(),
      'image_url': '🧃',
    },
  ];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 1000));

    final url = request.url.toString();
    
    // GET /products - получить все продукты
    if (request.method == 'GET' && url.contains('/products')) {
      final response = {
        'success': true,
        'data': _mockDatabase,
        'message': 'Products retrieved successfully',
      };
      
      return _mockResponse(200, json.encode(response));
    }
    
    // POST /products - добавить продукт
    if (request.method == 'POST' && url.contains('/products')) {
      final bodyBytes = await request.finalize().toBytes();
      final bodyString = utf8.decode(bodyBytes);
      final body = json.decode(bodyString) as Map<String, dynamic>;
      
      body['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      _mockDatabase.add(body);
      
      final response = {
        'success': true,
        'data': body,
        'message': 'Product added successfully',
      };
      
      return _mockResponse(201, json.encode(response));
    }
    
    // DELETE /products/:id - удалить продукт
    if (request.method == 'DELETE' && url.contains('/products/')) {
      final id = url.split('/').last;
      _mockDatabase.removeWhere((p) => p['id'] == id);
      
      final response = {
        'success': true,
        'message': 'Product deleted successfully',
      };
      
      return _mockResponse(200, json.encode(response));
    }
    
    // PUT /products/:id - обновить продукт
    if (request.method == 'PUT' && url.contains('/products/')) {
      final id = url.split('/').last;
      final bodyBytes = await request.finalize().toBytes();
      final bodyString = utf8.decode(bodyBytes);
      final body = json.decode(bodyString) as Map<String, dynamic>;
      
      final index = _mockDatabase.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _mockDatabase[index] = body;
        
        final response = {
          'success': true,
          'data': body,
          'message': 'Product updated successfully',
        };
        
        return _mockResponse(200, json.encode(response));
      }
    }
    
    // 404 Not Found
    return _mockResponse(404, json.encode({
      'success': false,
      'message': 'Endpoint not found',
    }));
  }

  http.StreamedResponse _mockResponse(int statusCode, String body) {
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      statusCode,
      headers: {
        'content-type': 'application/json',
      },
    );
  }
}

// Implementation с реальными HTTP запросами
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.get('/products');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> products = jsonData['data'];
        return products.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final response = await apiClient.post(
        '/products',
        body: product.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        throw ServerException('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await apiClient.delete('/products/$id');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await apiClient.put(
        '/products/${product.id}',
        body: product.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData['data']);
      } else {
        throw ServerException('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}