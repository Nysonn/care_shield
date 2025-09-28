import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/navigation/bottom_nav.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // If provider is still initializing we show a splash
        if (!auth.initialized) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
            theme: buildAppTheme(),
            debugShowCheckedModeBanner: false,
          );
        }

        // If logged in go to app shell, otherwise onboarding/login flow
        return MaterialApp(
          title: 'CareShield',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: auth.isAuthenticated
              ? const BottomNavScaffold()
              : const OnboardingScreen(),
          routes: {
            OnboardingScreen.routeName: (_) => const OnboardingScreen(),
            WelcomeScreen.routeName: (_) => const WelcomeScreen(),
            SignupScreen.routeName: (_) => const SignupScreen(),
            LoginScreen.routeName: (_) => const LoginScreen(),
            ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
            // Named route to app home for post-auth redirects
            '/home': (_) => const BottomNavScaffold(),
          },
        );
      },
    );
  }
}
