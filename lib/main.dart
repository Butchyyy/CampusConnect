import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await SupabaseService.initialize(
    supabaseUrl: 'https://iqxcuclvioyzuvaxkwhk.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxeGN1Y2x2aW95enV2YXhrd2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MzY3MjcsImV4cCI6MjA3OTUxMjcyN30.4tbdjjk4dcc0dQsT7DvcKB0Ca8HuRvvivZZxyG2Q6fM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}