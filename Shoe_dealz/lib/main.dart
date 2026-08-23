import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


import 'package:shoedealz/providers/cart_provider.dart';
import 'package:shoedealz/providers/theme_provider.dart'; 
import 'package:shoedealz/screens/splash/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ShoeDealzApp());
}

class ShoeDealzApp extends StatelessWidget {
  const ShoeDealzApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ShoeDealz',
            debugShowCheckedModeBanner: false,

          
            theme: ThemeData(
              fontFamily: 'Poppins', 
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            ),
            
            
            darkTheme: ThemeData.dark(),

            
            themeMode: themeProvider.themeMode,

            
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}