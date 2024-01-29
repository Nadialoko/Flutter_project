import 'dart:async';
import 'package:flutter/material.dart';
import 'MyHome.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<String> textLines = ["Bienvenue", "sur TextApp,"];
  double opacity = 0.0;
  int currentLineIndex = 0;

  @override
  void initState() {
    super.initState();
    _animateText();
    _navigateToMainScreen();
  }

  _navigateToMainScreen() async {
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHome()),
      );
    });
  }

  _animateText() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1.0;
      });
    });

    Future.delayed(Duration(milliseconds: 2000), () {
      _showNextLine();
    });
  }

  _showNextLine() {
    setState(() {
      currentLineIndex++;
      opacity = 0.0;
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        opacity = 1.0;
      });
    });

    if (currentLineIndex < textLines.length - 1) {
      Future.delayed(Duration(milliseconds: 3000), () {
        _showNextLine();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 3),
          opacity: opacity,
          child: Text(
            textLines[currentLineIndex],
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
