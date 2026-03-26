import '../entities/user.dart';
import '../repository_Abstract/auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  Future<User?> call() => _repository.signInWithGoogle();
}