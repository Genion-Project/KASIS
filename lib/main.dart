import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'pages/login_page.dart';
import 'widgets/connection_wrapper.dart';
import 'providers/member_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/violation_provider.dart';
import 'repositories/member_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/violation_repository.dart';

void main() {
  // Initialize FFI for Linux/Windows/MacOS
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MemberProvider(repository: MemberRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(repository: TransactionRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ViolationProvider(repository: ViolationRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'KASIS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        builder: (context, child) {
          return ConnectionWrapper(child: child!);
        },
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const MainScreen(),
        },
      ),
    );
  }
}