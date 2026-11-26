import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/consumer/consumer_home_screen.dart';

void main() {
  runApp(const BliptoConsumerApp());
}

class BliptoConsumerApp extends StatelessWidget {
  const BliptoConsumerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    appState.switchRole(AppRole.consumer);

    return MaterialApp(
      title: 'Blipto — 15-Min Neighborhood Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00B074),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B074),
          primary: const Color(0xFF00B074),
          secondary: const Color(0xFF0F172A),
        ),
      ),
      home: ConsumerHomeScreen(state: appState),
    );
  }
}
