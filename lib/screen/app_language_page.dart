import 'package:flutter/material.dart';


class Applanguage extends StatefulWidget {
  const Applanguage({super.key});

  @override
  State<Applanguage> createState() => _ApplanguageState();
}

class _ApplanguageState extends State<Applanguage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
     appBar: AppBar(
      title: const Text("Langugae"),
     ),
     body:const Text("App Language")


    );
  }
}