import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:athlete/Screens/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';



void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          accentColor: Color(0xFF00E676)),
      home: LandingPage(),
    );
  }
}

