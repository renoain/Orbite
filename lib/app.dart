import 'package:flutter/material.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/features/auth/presentation/pages/login_page.dart';
import 'package:orbite/features/interior/presentation/pages/interior_page.dart';
import 'package:orbite/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:orbite/features/planet_focus/presentation/pages/planet_focus_page.dart';
import 'package:orbite/features/solar_system/presentation/pages/home_page.dart';
import 'package:orbite/features/solar_system/presentation/pages/planet_list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: '/onboarding',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/onboarding';
    Widget page;
    switch (name) {
      case '/onboarding':
        page = const OnboardingPage();
        break;
      case '/login':
        page = const LoginPage();
        break;
      case '/home':
        page = const HomePage();
        break;
      case '/planets':
        page = const PlanetListPage();
        break;
      case '/focus':
        page = PlanetFocusPage(
          planetName: settings.arguments as String? ?? 'Planet',
        );
        break;
      case '/interior':
        page = InteriorPage(
          planetName: settings.arguments as String? ?? 'Planet',
        );
        break;
      default:
        page = const OnboardingPage();
    }
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: animation.drive(slide),
            child: child,
          ),
        );
      },
    );
  }
}
