import '../repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(
    String email,
    String password,
    String firstName,
    String lastName,
  ) =>
      _repository.signUpWithEmail(email, password, firstName, lastName);
}
