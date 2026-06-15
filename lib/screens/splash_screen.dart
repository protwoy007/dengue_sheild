import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../theme/app_theme.dart";
import "../providers/app_provider.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slide = Tween(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await context.read<AppProvider>().init();
    await Future.delayed(const Duration(milliseconds: 2600));
    if (mounted) Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value),
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(26)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset("assets/app_icon.png", fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 28),
                Text("DengueShield",
                  style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("BD  ", style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  Text("ডেঙ্গুশিল্ড বিডি", style: GoogleFonts.notoSansBengali(fontSize: 16, color: Colors.white70)),
                ]),
                const SizedBox(height: 12),
                Text("Predict. Protect. Prevent.",
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
                const SizedBox(height: 60),
                SizedBox(width: 36, height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.gold.withOpacity(0.7)))),
              ],
            )),
          ),
        ),
      ),
    );
  }
}
