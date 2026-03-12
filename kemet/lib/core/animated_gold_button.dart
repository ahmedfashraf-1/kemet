import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedGoldButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;

  const AnimatedGoldButton({super.key, required this.onTap, required this.text});

  @override
  State<AnimatedGoldButton> createState() => _AnimatedExploreButtonState();
}

class _AnimatedExploreButtonState extends State<AnimatedGoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), 
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment(-3.0 + (_controller.value * 4), -7.2),
                end: Alignment(0.0 + (_controller.value * 4), 2.2),
                
                colors: const [
                  Color(0xFF96703D), 
                  Color(0xFFE3B06C), 
                  Color(0xFF96703D),
                  Color.fromARGB(255,200, 160, 97), 
                  Color(0xFF96703D),
                  Color(0xFFDAAB5F), 
                  Color(0xFF96703D),
                ],
                stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
                tileMode: TileMode.mirror,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF96703D).withOpacity(0.8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: GoogleFonts.inter( 
                color: const Color.fromARGB(255, 33, 32, 18),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}