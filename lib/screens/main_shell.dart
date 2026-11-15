import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "../providers/app_provider.dart";
import "../theme/app_theme.dart";
import "../widgets/responsive.dart";
import "home_screen.dart";
import "map_screen.dart";
import "symptom_screen.dart";
import "alerts_screen.dart";
import "settings_screen.dart";
import "about_screen.dart";

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final s = p.s;

    final pages = IndexedStack(
      index: p.tab,
      children: const [
        HomeScreen(),
        MapScreen(),
        SymptomScreen(),
        AlertsScreen(),
      ],
    );

    // Wide screens (web / desktop / tablet landscape): side navigation.
    if (Responsive.isTablet(context)) {
      final extended = Responsive.isDesktop(context);
      return Scaffold(
        body: Row(children: [
          _SideNav(
            extended: extended,
            index: p.tab,
            onTap: p.setTab,
            labels: [s.navHome, s.navMap, s.navSymptoms, s.navAlerts],
            bn: p.isBengali,
            onLang: p.toggleLanguage,
            appName: s.appName,
          ),
          Expanded(child: pages),
        ]),
      );
    }

    // Phones: original bottom navigation bar.
    return Scaffold(
      body: pages,
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

class _SideNav extends StatelessWidget {
  final bool extended, bn;
  final int index;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final VoidCallback onLang;
  final String appName;
  const _SideNav({
    required this.extended, required this.index, required this.onTap,
    required this.labels, required this.bn, required this.onLang,
    required this.appName,
  });

  static const _icons = [
    (Icons.home_outlined, Icons.home),
    (Icons.map_outlined, Icons.map),
    (Icons.medical_information_outlined, Icons.medical_information),
    (Icons.notifications_outlined, Icons.notifications),
  ];

  @override
  Widget build(BuildContext context) {
    final w = extended ? 232.0 : 84.0;
    return Container(
      width: w,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF0D2233)],
        ),
      ),
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 22),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: extended ? 18 : 0),
            child: Row(
              mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset("assets/app_icon.png", width: 38, height: 38, fit: BoxFit.contain),
                ),
                if (extended) ...[
                  const SizedBox(width: 10),
                  Expanded(child: Text(appName, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (int i = 0; i < labels.length; i++)
            _NavItem(
              icon: index == i ? _icons[i].$2 : _icons[i].$1,
              label: labels[i], selected: index == i, extended: extended,
              onTap: () => onTap(i)),
          const Spacer(),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.translate, label: bn ? "English" : "বাংলা",
            selected: false, extended: extended, onTap: onLang),
          _NavItem(
            icon: Icons.settings_outlined, label: bn ? "সেটিংস" : "Settings",
            selected: false, extended: extended,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          _NavItem(
            icon: Icons.info_outline, label: bn ? "সম্পর্কে" : "About",
            selected: false, extended: extended,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AboutScreen(bn: bn)))),
          const SizedBox(height: 14),
        ]),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected, extended;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected,
    required this.extended, required this.onTap});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    final fg = sel ? AppColors.gold : (_hover ? Colors.white : const Color(0xFF90A4AE));
    final bg = sel
        ? Colors.white.withOpacity(0.10)
        : (_hover ? Colors.white.withOpacity(0.05) : Colors.transparent);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.extended ? 12 : 10, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.extended ? 14 : 0, vertical: widget.extended ? 12 : 10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: widget.extended
                ? Row(children: [
                    Icon(widget.icon, size: 22, color: fg),
                    const SizedBox(width: 12),
                    Expanded(child: Text(widget.label, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13.5,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: fg))),
                  ])
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(widget.icon, size: 22, color: fg),
                    const SizedBox(height: 3),
                    Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 9.5, color: fg)),
                  ]),
          ),
        ),
      ),
    );
  }
}
