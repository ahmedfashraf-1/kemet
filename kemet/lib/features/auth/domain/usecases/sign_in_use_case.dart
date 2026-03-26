import '../entities/user.dart';
import '../repository_Abstract/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<User> call(String email, String password) =>
      _repository.signInWithEmail(email, password);
}