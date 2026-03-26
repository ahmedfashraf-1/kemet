// send_verification_email_use_case.dart
import '../repository_Abstract/auth_repository.dart';

class SendVerificationEmailUseCase {
  const SendVerificationEmailUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.sendVerificationEmail();
}