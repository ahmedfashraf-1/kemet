import '../repository_Abstract/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(String email, String password) =>
      _repository.signUpWithEmail(email, password);
}