// send_password_reset_use_case.dart
import '../repository_Abstract/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(String email) => _repository.sendPasswordReset(email);
}