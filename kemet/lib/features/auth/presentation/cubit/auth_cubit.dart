import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import '../../domain/usecases/sign_in_with_google_use_case.dart';
import '../../domain/usecases/send_password_reset_use_case.dart';
import '../../domain/usecases/send_verification_email_use_case.dart';
import '../../domain/usecases/check_email_verified_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SendPasswordResetUseCase sendPasswordReset,
    required SendVerificationEmailUseCase sendVerificationEmail,
    required CheckEmailVerifiedUseCase checkEmailVerified,
    required SignOutUseCase signOut,
  }) : _signIn = signIn,
       _signUp = signUp,
       _signInWithGoogle = signInWithGoogle,
       _sendPasswordReset = sendPasswordReset,
       _sendVerificationEmail = sendVerificationEmail,
       _checkEmailVerified = checkEmailVerified,
       _signOut = signOut,
       super(const AuthInitial());

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SendPasswordResetUseCase _sendPasswordReset;
  final SendVerificationEmailUseCase _sendVerificationEmail;
  final CheckEmailVerifiedUseCase _checkEmailVerified;
  final SignOutUseCase _signOut;

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _signIn(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthLoading());
    try {
      await _signUp(email, password);
      emit(const AuthNeedsEmailVerification());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogle();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthInitial());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await _sendPasswordReset(email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _sendVerificationEmail();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkEmailVerified() async {
    try {
      final verified = await _checkEmailVerified();
      if (verified) emit(AuthEmailVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    emit(const AuthInitial());
  }
}
