import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_choice_screen.dart';
import 'screens/navigation_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const FamTaskApp(),
    ),
  );
}

class FamTaskApp extends StatelessWidget {
  const FamTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAMTASK - Family Task Manager',
      theme: FamTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: FamTheme.softBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: FamTheme.primary,
              ),
            ),
          );
        }

        if (state.currentUser == null) {
          return const WelcomeScreen();
        }

        if (state.currentUser!.familyId == null) {
          return const OnboardingChoiceScreen();
        }

        return const NavigationContainer();
      },
    );
  }
}
