import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/partner/presentation/screens/partner_main_navigation_screen.dart';
import 'features/auth/data/repository_implementations/auth_repository_impl.dart';
import 'features/auth/data/models/user_model.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'package:logger/logger.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const EcoSathiApp());
}

class EcoSathiApp extends StatelessWidget {
  const EcoSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthSessionEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'EcoSathi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (state.user.role == UserRole.partner) {
            return const PartnerMainNavigationScreen();
          }
          return const MainNavigationScreen();
        }
        if (state is Unauthenticated) {
          return const OnboardingScreen();
        }
        if (state is AuthError &&
            state.message.contains('Session check failed')) {
          return const OnboardingScreen();
        }
        // If we are in AuthError (during login/register) but not a session failure,
        // keep showing the onboarding/login/register stack by returning OnboardingScreen
        // as the base, or better, keep the current state if possible.
        if (state is AuthError || state is AuthInitial) {
          return const OnboardingScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
