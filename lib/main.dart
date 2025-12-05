import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// Your Firebase configuration
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyASI8Q5cZ7rGuGM0Vx78IRoHjsVC7I88pw',
      appId: '1:756900590328:android:5773e1dcd9e1360f9d410d',
      messagingSenderId: '756900590328',
      projectId: 'student-manager-d81e3',
      storageBucket: 'student-manager-d81e3.firebasestorage.app',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  try {
    // Initialize Supabase
    await SupabaseService.initialize(
      supabaseUrl: 'https://iqxcuclvioyzuvaxkwhk.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxeGN1Y2x2aW95enV2YXhrd2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MzY3MjcsImV4cCI6MjA3OTUxMjcyN30.4tbdjjk4dcc0dQsT7DvcKB0Ca8HuRvvivZZxyG2Q6fM',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🔵 AuthWrapper building...');

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔵 StreamBuilder rebuilding');
        print('🔵 Connection: ${snapshot.connectionState}');
        print('🔵 Has data: ${snapshot.hasData}');
        print('🔵 User: ${snapshot.data?.email ?? "null"}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // Show loading screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Waiting for auth state...');
          return _buildLoadingScreen(context);
        }

        // Handle errors
        if (snapshot.hasError) {
          print('❌ Stream error: ${snapshot.error}');
          return _buildErrorScreen(context, snapshot.error.toString());
        }

        // User is signed in - GO TO HOME SCREEN
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User authenticated - showing HomeScreen');
          print('✅ User email: ${snapshot.data!.email}');
          print('✅ User ID: ${snapshot.data!.uid}');
          return HomeScreen(key: ValueKey(snapshot.data!.uid)); // ✅ MUST HAVE THIS
        }
        // User is not signed in - SHOW LOGIN SCREEN
        print('❌ No user - showing LoginScreen');
        return const LoginScreen();
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}