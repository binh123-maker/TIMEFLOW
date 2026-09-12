import 'package:flutter/material.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chế độ Tập trung')),
      body: Center(
        child: Text(
          'Màn hình Tập trung (Pomodoro / Timer)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
