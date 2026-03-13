import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/routing/routes.dart';
import 'package:kemet/core/services/auth_service.dart';


class onLoginScreen extends StatefulWidget {
  const onLoginScreen({super.key});
  
  @override
  State<onLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<onLoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        children: [
          Image.asset(
            'images/onboarding1_bg.png', 
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F0D0B).withOpacity(0.2),
                  const Color(0xFF0A0E14).withOpacity(0.8),
                  const Color(0xFF1A120B).withOpacity(1.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 5.h),
                      const Spacer(flex: 3),

                      Transform.translate(
                        offset: Offset(0, 10.h),
                        child: Opacity(
                          opacity: 0.7,
                          child: Image.asset(
                            'images/KEMET Logo.png',
                            width: 170.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        'KEMET',
                        style: GoogleFonts.cormorant(
                          textStyle: TextStyle(
                            color: AppColors.mainGold,
                            fontSize: 46.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(0, 5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        'Explore the Legacy of Ancient Egypt',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 13.sp,
                          height: 1.6,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Email field 
                      _buildLabel('Email Address'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Kemet@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 16.h),

                      // Password field 
                      _buildLabel('Password'),
                      SizedBox(height: 8.h),
                      _buildPasswordField(),

                      SizedBox(height: 10.h),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              _showError('Enter your email first.');
                              return;
                            }
                            try {
                              final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
                              if (methods.isEmpty) {
                                _showError('No account found with this email.');
                                return;
                              }

                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              _showError('Reset email sent! Check your inbox.');
                            } catch (e) {
                              _showError(e.toString());
                            }
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.lightGold.withOpacity(0.55),
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      //  Sign In button 
                     AnimatedGoldButton(
                        text: _isLoading ? 'SIGNING IN...' : 'SIGN IN',
                        onTap: () async {
                          if (_isLoading) return; // guard at the top
                          if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                            _showError('Please fill in all fields.');
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            await _authService.signInWithEmail(
                              _emailController.text,
                              _passwordController.text,
                            );
                            if (mounted) context.pushNamed(Routes.OnHomeScreen);
                          } catch (e) {
                            _showError("No account found with this email. Please register first.");
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                      ),

                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.mainGold.withOpacity(0.20),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.mainGold.withOpacity(0.40),
                                fontSize: 11.sp,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.mainGold.withOpacity(0.20),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      _buildGoogleButton(),

                      const Spacer(flex: 2),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(Routes.onRegisterScreen);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.lightGold.withOpacity(0.55),
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account?  "),
                              TextSpan(
                                text: 'Create Account',
                                style: GoogleFonts.cormorant(
                                  textStyle: TextStyle(
                                    color: AppColors.mainGold,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Continue as guest 
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(Routes.OnHomeScreen);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue as Guest',
                              style: TextStyle(
                                color: AppColors.lightGold.withOpacity(0.40),
                                fontSize: 13.sp,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward,
                              size: 14.sp,
                              color: AppColors.lightGold.withOpacity(0.40),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 35.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.lightGold.withOpacity(0.65),
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.mainGold.withOpacity(0.30),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: AppColors.mainGold.withOpacity(0.06),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.mainGold.withOpacity(0.30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.mainGold.withOpacity(0.30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.mainGold, width: 1),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: TextStyle(
          color: AppColors.mainGold.withOpacity(0.30),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: AppColors.mainGold.withOpacity(0.06),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.mainGold.withOpacity(0.30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.mainGold.withOpacity(0.30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.mainGold, width: 1),
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.mainGold.withOpacity(0.55),
            size: 20.sp,
          ),
        ),
      ),
    );
  }
  Widget _buildGoogleButton() {
  return GestureDetector(
    onTap: () async {
      try {
        final result = await _authService.signInWithGoogle();
        if (result != null) context.pushNamed(Routes.OnHomeScreen);
      } catch (e) {
        _showError(e.toString());
      }
    },
    child: Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: AppColors.mainGold.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/google.png', 
            width: 22.w,
            height: 22.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Text(
            'Continue with Google',
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.mainGold.withOpacity(0.9),
    ),
  );
}
}

// Widget _buildGoogleButton() {
//   return GestureDetector(
//     onTap: () async {
//       try {
//         final result = await _authService.signInWithGoogle();
//         if (result != null) context.pushNamed(Routes.OnHomeScreen);
//       } catch (e) {
//         _showError(e.toString());
//       }
//     },
//     child: Container(
//       width: double.infinity,
//       height: 52.h,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         border: Border.all(color: AppColors.mainGold.withOpacity(0.25)),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             'images/google.png', 
//             width: 22.w,
//             height: 22.w,
//             fit: BoxFit.contain,
//           ),
//           SizedBox(width: 12.w),
//           Text(
//             'Continue with Google',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.80),
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// void _showError(String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(message),
//       backgroundColor: AppColors.mainGold.withOpacity(0.9),
//     ),
//   );
// }