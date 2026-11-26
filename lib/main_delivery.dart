import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/delivery/delivery_task_screen.dart';

void main() {
  runApp(const BliptoDeliveryApp());
}

class BliptoDeliveryApp extends StatelessWidget {
  const BliptoDeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    appState.switchRole(AppRole.deliveryStaff);

    return MaterialApp(
      title: 'Blipto Delivery — In-House Staff Run',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00B074),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B074),
          primary: const Color(0xFF00B074),
          secondary: const Color(0xFF0F172A),
        ),
      ),
      home: DeliveryTaskScreen(state: appState),
    );
  }
}
