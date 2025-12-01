import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:Center(child: const  Text('History Screen')),
      ),
      body: Center(
        child:const  Text('History Screen'),
      ),
    );
  }
}