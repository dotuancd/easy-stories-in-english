
import 'package:esie/screens/home.dart';
import 'package:esie/screens/post.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Stories in English',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/posts': (context) => PostScreen()
      },
      theme: ThemeData(
          primaryColor: Colors.green,
          textTheme: GoogleFonts.actorTextTheme().copyWith(bodyText2: TextStyle(fontSize: 16)),
      ),
    );
  }
}