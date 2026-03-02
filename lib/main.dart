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
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/orders/data/repository_implementations/orders_repository_impl.dart';
import 'features/partner/presentation/bloc/partner_bloc.dart';
import 'features/partner/data/repositories/partner_repository_impl.dart';
import 'features/pickup/presentation/bloc/pickup_bloc.dart';
import 'features/pickup/data/repositories/pickup_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/pickup/data/repositories/address_repository.dart';
import 'core/localization/language_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EcoSathiApp());
}

class EcoSathiApp extends StatelessWidget {
  const EcoSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepositoryImpl())..add(CheckAuthSessionEvent()),
        ),
        BlocProvider(create: (context) => OrdersBloc(OrdersRepositoryImpl())),
        BlocProvider(
          create: (context) => PartnerBloc(repository: PartnerRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => PickupBloc(repository: PickupRepository()),
        ),
        BlocProvider(
          create: (context) =>
              ProfileBloc(addressRepository: AddressRepository()),
        ),
        BlocProvider(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'EcoSathi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('kn'),
              Locale('hi'),
              Locale('te'),
              Locale('ta'),
            ],
            home: const AuthWrapper(),
          );
        },
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
        if (state is Unauthenticated || state is AuthError) {
          return const OnboardingScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
