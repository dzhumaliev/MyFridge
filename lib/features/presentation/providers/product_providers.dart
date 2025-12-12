import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';

// External Dependencies
final httpClientProvider = Provider<http.Client>((ref) {
  return MockHttpClient(); // ← MOCK HTTP CLIENT с тестовыми ответами
});

// Фильтры для категорий
final selectedCategoryProvider = StateProvider<ProductCategory?>((ref) => null);

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return products;
  }

  return products.whenData(
    (list) => list.where((p) => p.category == selectedCategory).toList(),
  );
});

final internetConnectionCheckerProvider = Provider<InternetConnectionChecker>(
  (ref) => InternetConnectionChecker(),
);

// Core
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(internetConnectionCheckerProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(client: ref.watch(httpClientProvider));
});

// Data Sources
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

// Repository
final productRepositoryProvider = Provider((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use Cases
final getProductsUseCaseProvider = Provider((ref) {
  return GetProducts(ref.watch(productRepositoryProvider));
});

final addProductUseCaseProvider = Provider((ref) {
  return AddProduct(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider((ref) {
  return DeleteProduct(ref.watch(productRepositoryProvider));
});

// State Management
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(
    ref.watch(getProductsUseCaseProvider),
    ref.watch(addProductUseCaseProvider),
    ref.watch(deleteProductUseCaseProvider),
  );
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final GetProducts getProducts;
  final AddProduct addProduct;
  final DeleteProduct deleteProduct;

  ProductsNotifier(this.getProducts, this.addProduct, this.deleteProduct)
      : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    final result = await getProducts(NoParams());
    
    result.fold(
      (failure) => state = AsyncValue.error('Ошибка загрузки', StackTrace.current),
      (products) => state = AsyncValue.data(products),
    );
  }

  Future<void> addNewProduct(Product product) async {
    final result = await addProduct(product);
    
    result.fold(
      (failure) => null,
      (newProduct) => loadProducts(),
    );
  }

  Future<void> removeProduct(String id) async {
    final result = await deleteProduct(id);
    
    result.fold(
      (failure) => null,
      (_) => loadProducts(),
    );
  }
}