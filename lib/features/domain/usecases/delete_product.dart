import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class DeleteProduct implements UseCase<bool, String> {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, bool>> call(String id) async {
    return await repository.deleteProduct(id);
  }
}