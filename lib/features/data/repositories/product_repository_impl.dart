import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts();
        return Right(products);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    if (await networkInfo.isConnected) {
      try {
        final productModel = ProductModel.fromEntity(product);
        final result = await remoteDataSource.addProduct(productModel);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteProduct(id);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    if (await networkInfo.isConnected) {
      try {
        final productModel = ProductModel.fromEntity(product);
        final result = await remoteDataSource.updateProduct(productModel);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}