import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showJoinKemetDialog(BuildContext context) {
  debugPrint('dialog called: JOIN KEMET');
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0C06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '𓂀',
              style: TextStyle(fontSize: 42, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 16),
            Text(
              'JOIN KEMET',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFD4AF37),
                fontSize: 18,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create an account to unlock your profile, save favorite places, and track your Egyptian journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/onLoginScreen');
                },
                child: Text(
                  'SIGN IN / REGISTER',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue as Guest',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

bool requireAuthOrShowDialog(
  BuildContext context, {
  required bool isGuest,
  required VoidCallback action,
  String debugLabel = 'auth-guard',
}) {
  debugPrint('tap fired: $debugLabel');
  if (isGuest) {
    debugPrint('guest detected: $debugLabel');
    debugPrint('navigation blocked: $debugLabel');
    showJoinKemetDialog(context);
    return false;
  }

  action();
  return true;
}

