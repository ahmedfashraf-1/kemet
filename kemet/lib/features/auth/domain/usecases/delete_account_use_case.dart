// lib/features/auth/domain/usecases/delete_account_use_case.dart

import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repo;
  DeleteAccountUseCase(this._repo);

  Future<void> call() => _repo.deleteAccount();
}