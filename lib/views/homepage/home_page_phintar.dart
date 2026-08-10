import 'package:flutter/material.dart';

class HomePagePhintar extends StatefulWidget {
  const HomePagePhintar({super.key});

  @override
  State<HomePagePhintar> createState() => _HomePagePhintarState();
}

class _HomePagePhintarState extends State<HomePagePhintar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("INI home page")));
  }
}
