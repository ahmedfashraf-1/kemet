// sign_out_use_case.dart
import '../repository_Abstract/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}