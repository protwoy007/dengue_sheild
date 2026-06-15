import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "home_screen.dart";
import "map_screen.dart";
import "symptom_screen.dart";
import "alerts_screen.dart";

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;

    return Scaffold(
      body: IndexedStack(
        index: p.tab,
        children: const [
          HomeScreen(),
          MapScreen(),
          SymptomScreen(),
          AlertsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: p.tab,
        onTap: p.setTab,
        backgroundColor: AppColors.navy,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: const Color(0xFF78909C),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: s.navHome),
          BottomNavigationBarItem(icon: const Icon(Icons.map_outlined), activeIcon: const Icon(Icons.map), label: s.navMap),
          BottomNavigationBarItem(icon: const Icon(Icons.medical_information_outlined), activeIcon: const Icon(Icons.medical_information), label: s.navSymptoms),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications_outlined), activeIcon: const Icon(Icons.notifications), label: s.navAlerts),
        ],
      ),
    );
  }
}
