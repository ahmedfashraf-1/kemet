import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/auth/domain/usecases/delete_account_use_case.dart';
import 'package:kemet/features/notifications/data/datasources/Local_notification.dart';
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
    required DeleteAccountUseCase deleteAccount,
  }) : _signIn = signIn,
       _signUp = signUp,
       _signInWithGoogle = signInWithGoogle,
       _sendPasswordReset = sendPasswordReset,
       _sendVerificationEmail = sendVerificationEmail,
       _checkEmailVerified = checkEmailVerified,
       _signOut = signOut,
       _deleteAccount = deleteAccount,
       
       super(const AuthInitial());

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SendPasswordResetUseCase _sendPasswordReset;
  final SendVerificationEmailUseCase _sendVerificationEmail;
  final CheckEmailVerifiedUseCase _checkEmailVerified;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _signIn(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      final verified = await _checkEmailVerified();
      if (verified) {
        await LocalNotificationService.instance.showWelcomeNotification(
          userName: user.username,
          userId: user.id,
        );

        emit(AuthAuthenticated(user));
        await prefs.setString('current_user_id', user.id);
        await LocalNotificationService.instance
            .scheduleReEngagementNotification();
      } else {
        emit(const AuthNeedsEmailVerification());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    emit(const AuthLoading());
    try {
      await _signUp(email, password, firstName, lastName);
      // Keep the user session active and send verification immediately.
  
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await _sendVerificationEmail();
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
        await LocalNotificationService.instance.showWelcomeNotification(
          userName: user.username,
          userId: user.id,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        emit(AuthAuthenticated(user));
        await prefs.setString('current_user_id', user.id);
        await LocalNotificationService.instance
            .scheduleReEngagementNotification();
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
    emit(const AuthLoading());
    try {
      final verified = await _checkEmailVerified();
      if (verified) {
        emit(AuthEmailVerified());
      } else {
        emit(
          const AuthError(

            'Please verify your email first before continuing.',
          ),
        );
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {

    emit(const AuthLoading());
    try {
      await _signOut();
    } catch (_) {
      // Keep sign-out flow stable even if remote cleanup fails.
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('current_user_id');
    } catch (_) {
      // Ignore local storage failures and still reset UI state.
    }

    await LocalNotificationService.instance.cancelReEngagementNotification();

    emit(const AuthInitial());
  }

Future<void> deleteAccount() async {
  emit(const AuthLoading());
  try {
    await _deleteAccount();
    
    // clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    emit(const AuthInitial());
  } catch (e) {
    emit(AuthError(e.toString()));
  }
}
  
}
