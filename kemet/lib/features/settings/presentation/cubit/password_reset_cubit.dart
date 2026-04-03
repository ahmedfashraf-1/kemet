import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
}

class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
}

class PasswordResetSuccess extends PasswordResetState {
  const PasswordResetSuccess();
}

class PasswordResetError extends PasswordResetState {
  const PasswordResetError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit() : super(const PasswordResetInitial());

  Future<void> sendResetLink(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      emit(const PasswordResetError('Please enter your email address.'));
      return;
    }

    emit(const PasswordResetLoading());

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmedEmail);
      emit(const PasswordResetSuccess());
    } on FirebaseAuthException catch (_) {
      emit(const PasswordResetError('Invalid email or user not found'));
    } catch (_) {
      emit(const PasswordResetError('Invalid email or user not found'));
    }
  }
}
