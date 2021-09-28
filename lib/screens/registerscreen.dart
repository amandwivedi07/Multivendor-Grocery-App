import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Hero(tag: 'Logo',
                 child: Image.asset('images/logo.jpeg')),
              TextField(),
              TextField(),
              TextField(),
              TextField(),
            ],
          ),
        ),
      ),
    );
  }
}
