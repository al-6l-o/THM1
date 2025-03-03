import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_h_m/Screens/add_beds/add_beds_screen.dart';
import 'Screens/welcome/welcome_screen.dart';
import 'Providers/theme_provider.dart';
import 'package:t_h_m/Theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // bool isFirstTime = prefs.getBool('first_time') ?? true;

  // if (isFirstTime) {
  //   await prefs.setBool(
  //       'first_time', false); // تحديث القيمة حتى لا تظهر مرة أخرى
  // }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
      //isFirstTime: isFirstTime   هذا السطر داخل اقواس MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  // final bool isFirstTime;
  // const MyApp({required this.isFirstTime, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme, // استخدام الثيم الفاتح
      darkTheme: AppTheme.darkTheme, // استخدام الثيم الداكن
      home:
          // isFirstTime ?
          WelcomeScreen(),
      //: AddBedsScreen(),
    );
  }
}
