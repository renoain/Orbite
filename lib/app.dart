import 'package:flutter/material.dart';
import 'package:orbite/core/theme/app_theme.dart';
import 'package:orbite/features/auth/presentation/pages/login_page.dart';
import 'package:orbite/features/constellation/presentation/pages/constellation_page.dart';
import 'package:orbite/features/eclipse/presentation/pages/eclipse_page.dart';
import 'package:orbite/features/home/presentation/pages/cosmic_explore.dart';
import 'package:orbite/features/interior/presentation/pages/interior_page.dart';
import 'package:orbite/features/moon_phases/presentation/pages/moon_phases_page.dart';
import 'package:orbite/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:orbite/features/planet_detail/presentation/pages/planet_detail_page.dart';
import 'package:orbite/features/planet_focus/presentation/pages/planet_focus_page.dart';
import 'package:orbite/features/quiz/presentation/pages/quiz_page.dart';
import 'package:orbite/features/seasons/presentation/pages/seasons_page.dart';
import 'package:orbite/features/solar_system/presentation/pages/home_page.dart';
import 'package:orbite/features/solar_system/presentation/pages/planet_compare_page.dart';
import 'package:orbite/features/solar_system/presentation/pages/planet_list_page.dart';
import 'package:orbite/features/solar_system/presentation/pages/solar_system_page.dart';

import 'home/trivia_route.dart';

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
      case '/explore':
        page = const CosmicExplore();
        break;
      case '/planets':
        page = const PlanetListPage();
        break;
      case '/compare':
        page = const PlanetComparePage();
        break;
      case '/solar-system':
        page = const SolarSystemPage();
        break;
      case '/moon-phases':
        page = const MoonPhasesPage();
        break;
      case '/seasons':
        page = const SeasonsPage();
        break;
      case '/eclipse':
        page = const EclipsePage();
        break;
      case '/constellations':
        page = const ConstellationPage();
        break;
      case '/trivia':
        page = const TriviaRoutePage();
        break;
      case '/focus':
        page = PlanetFocusPage(
          planetName: settings.arguments as String? ?? 'Planet',
        );
        break;
      case '/detail':
        page = PlanetDetailPage(
          planetName: settings.arguments as String? ?? 'Planet',
        );
        break;
      case '/interior':
        page = InteriorPage(
          planetName: settings.arguments as String? ?? 'Planet',
        );
        break;
      case '/quiz':
        page = QuizPage(planetName: settings.arguments as String? ?? 'Planet');
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
