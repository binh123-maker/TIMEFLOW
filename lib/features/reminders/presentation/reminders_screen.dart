import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhắc nhở')),
      body: Center(
        child: Text(
          'Màn hình Nhắc nhở',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
