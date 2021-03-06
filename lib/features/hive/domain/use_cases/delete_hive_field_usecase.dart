import 'package:hospital_patient/core/helper/type_aliases.dart';
import 'package:hospital_patient/core/usecase/usecase.dart';
import 'package:hospital_patient/features/hive/domain/repositories/hive_repository.dart';

class DeleteHiveFieldUsecase extends Usecase<bool, String> {
  DeleteHiveFieldUsecase({
    required this.repository,
  });

  final HiveRepository repository;

  @override
  FutureFailable<bool> call(String param) {
    return repository.deleteField(param);
  }
}
