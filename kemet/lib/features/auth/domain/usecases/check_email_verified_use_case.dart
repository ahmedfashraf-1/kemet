// check_email_verified_use_case.dart
import '../repository_Abstract/auth_repository.dart';

class CheckEmailVerifiedUseCase {
  const CheckEmailVerifiedUseCase(this._repository);
  final AuthRepository _repository;

  Future<bool> call() => _repository.checkEmailVerified();
}