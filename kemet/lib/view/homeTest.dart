import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import 'package:kemet/core/animated_gold_button.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/routing/routes.dart';

class OnHomeScreen extends StatelessWidget {
  const OnHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:Color.fromARGB(255, 64, 59, 59),
      body: Center(
        child: Text(
          "HOME",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}